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

logic [WIDTH - 1 : 0] [ $clog2(WIDTH) : 0] interm_result_new;

always_comb
	for ( int i = 0; i < WIDTH; i++ )
		interm_result_new[i] = ( i == 0 ) ? ( data_i[i] ) :
		                                    ( interm_result_new[i-1] + data_i[i] );


always_ff @(posedge clk_i)
	begin : data_pipeline_output
		data_o     <= interm_result_new[ WIDTH - 1 ];
		data_val_o <= data_val_i;
	end


endmodule
