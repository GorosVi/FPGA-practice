module TOP (
	input  wire        clk_i,
	input  wire        srst_i,

	input  wire  [2:0] cmd_type_i,
	input  wire  [9:0] cmd_data_i,
	input  wire        cmd_valid_i,

	output logic [4:0] hours_o,
	output logic [5:0] minutes_o,
	output logic [5:0] seconds_o,
	output logic [9:0] milliseconds_o
);


rtc_clock i_rtc_clock (
	.clk_i          ( clk_i          ),
	.srst_i         ( srst_i         ),

	.cmd_type_i     ( cmd_type_i     ),
	.cmd_data_i     ( cmd_data_i     ),
	.cmd_valid_i    ( cmd_valid_i    ),

	.hours_o        ( hours_o        ),
	.minutes_o      ( minutes_o      ),
	.seconds_o      ( seconds_o      ),
	.milliseconds_o ( milliseconds_o )
);


endmodule
