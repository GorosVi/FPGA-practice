`timescale 10 ps / 10 ps

module tb;

localparam CLK_HALF_PERIOD = 5;

logic clk;
logic srst;
logic key_i;
logic key_o;


localparam CLK_FREQ_MHZ = 20;
localparam GLITCH_TIME_NS = 1600;
localparam GLITCH_TIME_CLK = GLITCH_TIME_NS * CLK_FREQ_MHZ / ( 10 ** 3 );


debouncer #(
	.CLK_FREQ_MHZ      ( CLK_FREQ_MHZ ),
	.GLITCH_TIME_NS    ( GLITCH_TIME_NS )
) i_debouncer (
	.clk_i             ( clk ),
	.srst_i            ( srst ),
	.key_i             ( key_i ),
	.key_pressed_stb_o ( key_o )
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
		// idle - key released
		key_i = 1'b1;

		repeat (2) @( posedge clk );
		repeat (GLITCH_TIME_CLK / 2)
			begin
				key_i = 1'b0;
				@(posedge clk);
				key_i = 1'b1;
				@(posedge clk);
			end
		key_i = 1'b0;

		repeat (25) @( posedge clk );

		repeat (2) @( posedge clk );
		repeat (GLITCH_TIME_CLK / 2)
			begin
				key_i = 1'b1;
				@(posedge clk);
				key_i = 1'b0;
				@(posedge clk);
			end
		key_i = 1'b1;

		repeat (25) @( posedge clk );

		key_i = 1'b0;
		repeat (10) @( posedge clk );
		$stop;
	end


endmodule
