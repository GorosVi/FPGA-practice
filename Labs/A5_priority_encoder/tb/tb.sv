`timescale 10 ps / 10 ps

module tb;

localparam WIDTH = 4;
localparam CLK_HALF_PERIOD = 5;

logic             clk;
logic             srst;
logic [WIDTH-1:0] data;
logic [WIDTH-1:0] data_left;
logic [WIDTH-1:0] data_right;


priority_encoder #(
	.WIDTH        (WIDTH       )
	) i_priority_encoder (
	.clk_i        (clk         ),
	.srst_i       (srst        ),
	.data_i       (data        ),
	.data_left_o  (data_left   ),
	.data_right_o (data_right  )
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
	begin : data_incrementer
		data = 0;
		@( posedge clk );
		forever begin
			@( posedge clk );
			data = data + 1;
		end
	end

initial
	begin : run_time_limiter
		repeat (16) @( posedge clk );
		$stop;
	end
endmodule