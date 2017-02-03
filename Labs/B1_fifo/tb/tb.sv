`timescale 10 ps / 10 ps

module tb;

localparam CLK_HALF_PERIOD = 5;
localparam DWIDTH = 8,
           AWIDTH = 2;

logic              clk_i;
logic              srst_i;

logic              wrreq_i;
logic              rdreq_i;
logic [DWIDTH-1:0] data_i;

logic [DWIDTH-1:0] q_o;
logic              empty_o;
logic              full_o;
logic [AWIDTH-1:0] usedw_o;


fifo #(
	.AWIDTH  ( AWIDTH  ),
	.DWIDTH  ( DWIDTH  )
) i_fifo (
	.clk_i   ( clk_i   ),
	.srst_i  ( srst_i  ),

	.data_i  ( data_i  ),
	.wrreq_i ( wrreq_i ),
	.rdreq_i ( rdreq_i ),

	.q_o     ( q_o     ),
	.empty_o ( empty_o ),
	.full_o  ( full_o  ),
	.usedw_o ( usedw_o )
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
		rdreq_i = 0;
		wrreq_i = 0;
		data_i  = 0;
		repeat (5) @( posedge clk_i );

		repeat (7)
			begin
				wrreq_i = 1'b1;
				data_i = data_i + 1;
				@( posedge clk_i );
				wrreq_i = 0;
			end

		repeat (5) @( posedge clk_i );

		repeat (7)
			begin
				rdreq_i = 1'b1;
				data_i = data_i + 1;
				@( posedge clk_i );
				rdreq_i = 0;
			end

		repeat (5) @( posedge clk_i );

		$stop;
	end


endmodule
