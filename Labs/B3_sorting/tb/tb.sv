`timescale 10 ps / 10 ps

module tb;

localparam CLK_HALF_PERIOD = 5;
localparam DWIDTH = 8,
           AWIDTH = 3;

logic              clk_i;
logic              srst_i;

logic              sop_i;
logic              eop_i;
logic              val_i;
logic [DWIDTH-1:0] data_i;

logic              sop_o;
logic              eop_o;
logic              val_o;
logic [DWIDTH-1:0] data_o;

logic              busy_o;

sorting #(
	.AWIDTH  ( AWIDTH ),
	.DWIDTH  ( DWIDTH )
) i_sorting (
	.clk_i   ( clk_i  ),
	.srst_i  ( srst_i ),

	.data_i  ( data_i ),
	.sop_i   ( sop_i  ),
	.eop_i   ( eop_i  ),
	.val_i   ( val_i  ),

	.data_o  ( data_o ),
	.sop_o   ( sop_o  ),
	.eop_o   ( eop_o  ),
	.val_o   ( val_o  ),

	.busy_o  ( busy_o )
);



initial
	begin : clk_generator
		clk_i = 1'b0;
		forever #CLK_HALF_PERIOD clk_i = ~clk_i;
	end


initial
	begin : sync_reset_generator
		srst_i = 1'b1;
		#( CLK_HALF_PERIOD + 1 ) srst_i = 1'b0;
	end


initial
	begin : test_sequence_generator
		data_i = 0;
		sop_i  = 0;
		eop_i  = 0;
		val_i  = 0;
		repeat (5) @( posedge clk_i );

		sop_i  = 1'b1;
		val_i  = 1'b1;
		data_i = 'h0a;
		@( posedge clk_i );
		sop_i  = 0;
		data_i = 'h07;
		@( posedge clk_i );
		data_i = 'h04;
		@( posedge clk_i );
		eop_i  = 1'b1;
		data_i = 'h0d;
		@( posedge clk_i );
		eop_i  = 0;
		val_i  = 0;

		repeat (5) @( posedge clk_i );

		repeat (5) @( posedge clk_i );
		$stop;
	end


endmodule
