`timescale 10 ps / 10 ps

module tb;

localparam WIDTH = 8;
localparam CLK_HALF_PERIOD = 5;

logic clk;
logic srst;

logic [WIDTH - 1 : 0]       data_i;
logic                       data_val_i;

logic [$clog2(WIDTH)-1 : 0] data_o;
logic                       data_val_o;


bit_population_counter #(
	.WIDTH      ( WIDTH      )
) i_bit_population_counter (
	.clk_i      ( clk        ),
	.srst_i     ( srst       ),
	.data_i     ( data_i     ),
	.data_val_i ( data_val_i ),
	.data_o     ( data_o     ),
	.data_val_o ( data_val_o )
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
		repeat (10) @( posedge clk );
		$stop;
	end


endmodule
