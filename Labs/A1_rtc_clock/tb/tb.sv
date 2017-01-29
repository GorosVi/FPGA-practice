`timescale 10 ps / 10 ps

module tb;

localparam CLK_HALF_PERIOD = 5;
localparam WIDTH           = 16;

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

		cmd_type_i = 3'b001;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		repeat (15) @( posedge clk );

		cmd_type_i = 3'b111;
		cmd_data_i = 'd23;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		repeat (15) @( posedge clk );

		cmd_type_i = 3'b110;
		cmd_data_i = 'd59;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		repeat (15) @( posedge clk );

		cmd_type_i = 3'b101;
		cmd_data_i = 'd59;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		repeat (15) @( posedge clk );

		cmd_type_i = 3'b100;
		cmd_data_i = 'd2;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		repeat (15) @( posedge clk );

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

		cmd_type_i = 3'b000;
		cmd_valid_i = 1'b1;
		@( posedge clk );
		cmd_valid_i = 1'b0;
		repeat (15) @( posedge clk );

		$stop;
	end


endmodule
