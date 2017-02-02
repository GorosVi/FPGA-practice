`timescale 10 ps / 10 ps

module tb;

localparam CLK_HALF_PERIOD = 5;
localparam WIDTH           = 16;

localparam logic [2:0] RESET_CMD    = 3'b000,
                       SET12H_CMD   = 3'b001,
                       SET_MSEC_CMD = 3'b100,
                       SET_SEC_CMD  = 3'b101,
                       SET_MIN_CMD  = 3'b110,
                       SET_HOUR_CMD = 3'b111;

logic             clk;
logic             srst;

logic [2:0] cmd_type_i;
logic [9:0] cmd_data_i;
logic       cmd_valid_i;

logic [4:0] hours_o;
logic [5:0] minutes_o;
logic [5:0] seconds_o;
logic [9:0] milliseconds_o;

rtc_clock i_rtc_clock (
	.clk_i          ( clk            ),
	.srst_i         ( srst           ),

	.cmd_type_i     ( cmd_type_i     ),
	.cmd_data_i     ( cmd_data_i     ),
	.cmd_valid_i    ( cmd_valid_i    ),

	.hours_o        ( hours_o        ),
	.minutes_o      ( minutes_o      ),
	.seconds_o      ( seconds_o      ),
	.milliseconds_o ( milliseconds_o )
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
		repeat (15) @( posedge clk );

		cmd_type_i = SET12H_CMD;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		repeat (15) @( posedge clk );

		cmd_type_i = SET_HOUR_CMD;
		cmd_data_i = 'd23;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		@( posedge clk );
		assert ( hours_o == 'd23 ) else $error("Command SET_HOUR_CMD was not executed");
		repeat (15) @( posedge clk );

		cmd_type_i = SET_MIN_CMD;
		cmd_data_i = 'd59;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		@( posedge clk );
		assert ( minutes_o == 'd59 ) else $error("Command SET_MIN_CMD was not executed");
		repeat (15) @( posedge clk );

		cmd_type_i = SET_SEC_CMD;
		cmd_data_i = 'd59;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		@( posedge clk );
		assert ( seconds_o == 'd59 ) else $error("Command SET_SEC_CMD was not executed");
		repeat (15) @( posedge clk );

		cmd_type_i = SET_MSEC_CMD;
		cmd_data_i = 'd990;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		@( posedge clk );
		assert ( milliseconds_o == 'd990 ) else $error("Command SET_MSEC_CMD was not executed");
		repeat (10) @( posedge clk );
		assert ( ( hours_o == 0 ) && ( minutes_o == 0 ) && ( seconds_o == 0 ) && ( milliseconds_o == 0 ) )
		       else $error("Overflow is not correct");

		cmd_type_i = 3'b010;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		repeat (15) @( posedge clk );

		cmd_type_i = 3'b011;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		repeat (15) @( posedge clk );

		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		repeat (15) @( posedge clk );

		cmd_type_i = SET12H_CMD;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_type_i = SET_MIN_CMD;
		@( posedge clk );
		cmd_type_i = SET_SEC_CMD;
		@( posedge clk );
		cmd_type_i = RESET_CMD;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		@( posedge clk );
			assert ( ( hours_o == 0 ) && ( minutes_o == 0 ) && ( seconds_o == 0 ) && ( milliseconds_o == 0 ) )
		       else $error("Result of RESET_CMD is not correct");
		repeat (15) @( posedge clk );

		$stop;
	end


endmodule
