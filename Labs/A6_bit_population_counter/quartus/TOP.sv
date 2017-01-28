module TOP #(
	parameter WIDTH = 8
)(
	input  wire                    clk_i,
	input  wire                    srst_i,

	input  wire  [WIDTH - 1 : 0]   data_i,
	input  wire                    data_val_i,

	output logic [$clog2(WIDTH) - 1 : 0] data_o,
	output logic                   data_val_o
);


bit_population_counter #(
	.WIDTH      ( WIDTH      )
) i_bit_population_counter (
	.clk_i      ( clk_i      ),
	.srst_i     ( srst_i     ),
	.data_i     ( data_i     ),
	.data_val_i ( data_val_i ),
	.data_o     ( data_o     ),
	.data_val_o ( data_val_o )
);


endmodule
