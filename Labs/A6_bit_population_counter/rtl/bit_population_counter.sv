module bit_population_counter #(
	parameter WIDTH = 8
)(
	input  wire                        clk_i,
	input  wire                        srst_i,

	input  wire  [ WIDTH - 1 : 0]      data_i,
	input  wire                        data_val_i,

	output logic [ $clog2(WIDTH) : 0 ] data_o,
	output logic                       data_val_o
);

localparam CONV_DEPTH = $clog2(WIDTH);
initial
begin
	assert ( CONV_DEPTH == 0 ) $error ("Input data width = %d is too small for module", WIDTH);
	assert ( WIDTH > 128     ) $error ("Input data width = %d is too big for module, max width = 128", WIDTH);
end

logic [CONV_DEPTH - 1 : 0]                interm_valid;
logic [CONV_DEPTH - 1 : 0][WIDTH - 1 : 0] interm_result;
logic [CONV_DEPTH - 1 : 0][WIDTH - 1 : 0] interm_result_new;


always_ff @(posedge clk_i)
	begin: data_pipeline
		if ( srst_i )
			interm_valid [CONV_DEPTH - 1 : 0] <= 0;
		else
			begin
				interm_result[0] <= data_i;
				interm_valid[0]  <= data_val_i;
				for ( int i = 1; i < CONV_DEPTH; i++ )
					begin
						interm_result[ i ] <= interm_result_new [ i - 1 ];
						interm_valid[ i ]  <= interm_valid [ i - 1 ];
					end
			end
	end


localparam [0:6][127:0] bit_mask_array = {128'h55555555555555555555555555555555,
                                          128'h33333333333333333333333333333333,
                                          128'h0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F,
                                          128'h00FF00FF00FF00FF00FF00FF00FF00FF,
                                          128'h0000FFFF0000FFFF0000FFFF0000FFFF,
                                          128'h00000000FFFFFFFF00000000FFFFFFFF,
                                          128'h0000000000000000FFFFFFFFFFFFFFFF};
always_comb
	begin: new_pipeline_values
		for ( int i = 0; i < CONV_DEPTH; i++ )
			// In each step we adds half of bits with other half of bits, selected by bit-mask
			interm_result_new[i] = ( ( ( interm_result[i] >> ( 2 ** i ) ) & bit_mask_array[i] )
				                       + ( interm_result[i] & bit_mask_array[i] ) );
	end


// Data pipeline output. Last stage is not latched for speed optimisation (sometimes it may be bad solution)
assign data_o     = interm_result_new[ CONV_DEPTH - 1][$clog2(WIDTH):0];
assign data_val_o = interm_valid[ CONV_DEPTH - 1 ];


endmodule
