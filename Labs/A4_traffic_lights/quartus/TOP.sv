module TOP (
	input  wire         clk_i,
	input  wire         srst_i,

	input  wire  [2:0]  cmd_type_i,
	input  wire  [15:0] cmd_data_i,
	input  wire         cmd_valid_i,

	output logic red_o,
	output logic yellow_o,
	output logic green_o
);


traffic_lights i_traffic_lights (
	.clk_i       ( clk_i       ),
	.srst_i      ( srst_i      ),

	.cmd_type_i  ( cmd_type_i  ),
	.cmd_data_i  ( cmd_data_i  ),
	.cmd_valid_i ( cmd_valid_i ),

	.red_o       ( red_o       ),
	.yellow_o    ( yellow_o    ),
	.green_o     ( green_o     )
);


endmodule
