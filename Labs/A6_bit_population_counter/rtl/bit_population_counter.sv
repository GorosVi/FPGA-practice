module bit_population_counter #(
	parameter WIDTH = 8
) (
	input  wire                        clk_i,
	input  wire                        srst_i,

	input  wire  [ WIDTH - 1 : 0]      data_i,
	input  wire                        data_val_i,

	output logic [ $clog2(WIDTH) : 0 ] data_o,
	output logic                       data_val_o
);

// Assert on zero input !
localparam CONV_DEPTH = $clog2(WIDTH);
initial
begin
	$warning("CONV_DEPTH %d",CONV_DEPTH);
end

logic [CONV_DEPTH - 1 : 0]                interm_valid;
logic [CONV_DEPTH - 1 : 0][WIDTH - 1 : 0] interm_result;
logic [CONV_DEPTH - 1 : 0][WIDTH - 1 : 0] interm_result_new;


always_ff @(posedge clk_i)
	begin : data_pipeline
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

localparam [4:0][15:0] const_array = {32'h0000ffff, 32'h00ff00ff, 32'h0f0f0f0f, 32'h33333333, 32'h55555555};

always_comb
	begin
		for ( int i = 0; i < CONV_DEPTH; i++ )
			interm_result_new[i] = ( ( ( interm_result[i] >> ( 2 ** i ) ) & const_array[i] ) + ( interm_result[i] & const_array[i] ) );
	end

// Data pipeline output. Last stage is not latched for speed optimisation (may be sometimes bad solution)
assign data_o     = interm_result_new[ CONV_DEPTH - 1 ] ;
assign data_val_o = interm_valid[ CONV_DEPTH - 1 ];


endmodule
