`timescale 10 ps / 10 ps

module tb;

localparam CLK_HALF_PERIOD = 5;

logic       clk;
logic       srst;

logic [2:0] cmd_type_i;
logic [15:0] cmd_data_i;
logic       cmd_valid_i;

logic       red_o;
logic       yellow_o;
logic       green_o;

localparam [2:0]
	CMD_ON             = 3'd0,
	CMD_OFF            = 3'd1,
	CMD_OFF_CONTROL    = 3'd2,
	CMD_SET_GREEN_TIME = 3'd3,
	CMD_SET_RED_TIME   = 3'd4,
	CMD_SET_YELOW_TIME = 3'd5;


traffic_lights #(
	.BLINK_HALF_PERIOD ( 2 ),  // (ms)
	.GREEN_BLINKS_NUM  ( 2 ),
	.RED_YELLOW_TIME   ( 2 )  // (ms)
) i_traffic_lights (
	.clk_i       ( clk         ),
	.srst_i      ( srst        ),

	.cmd_type_i  ( cmd_type_i  ),
	.cmd_data_i  ( cmd_data_i  ),
	.cmd_valid_i ( cmd_valid_i ),

	.red_o       ( red_o       ),
	.yellow_o    ( yellow_o    ),
	.green_o     ( green_o     )
);


initial
	begin : clk_generator
		clk = 1'b0;
		forever #CLK_HALF_PERIOD clk = ~clk;
	end


initial
	begin : sync_reset_generator
		srst = 1'b1;
		#( CLK_HALF_PERIOD + 1 ) srst = 1'b0;
	end


initial
	begin : test_sequence_generator
		cmd_valid_i = 1'b0;
		repeat (5) @( posedge clk );

		// OFF command
		cmd_type_i = CMD_OFF;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		repeat (15) @( posedge clk );

		// Set short red time
		cmd_type_i = CMD_SET_RED_TIME;
		cmd_data_i = 'd5; // 5 clock cycles
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		// @( posedge clk );

		// Set short yellow time
		cmd_type_i = CMD_SET_YELOW_TIME;
		cmd_data_i = 'd3; // 3 clock cycles
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		@( posedge clk );

		// Set short green time
		cmd_type_i = CMD_SET_GREEN_TIME;
		cmd_data_i = 'd4; // 4 clock cycles
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		@( posedge clk );

		// Switch to yellow_blink state
		cmd_type_i = CMD_OFF_CONTROL;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		repeat (30) @( posedge clk );

		// Enable automatic control
		cmd_type_i = CMD_ON;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		// repeat (30) @( posedge clk );

		repeat (50) @( posedge clk );

		// OFF command
		cmd_type_i = CMD_OFF;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		repeat (15) @( posedge clk );

		$stop;
	end


endmodule
