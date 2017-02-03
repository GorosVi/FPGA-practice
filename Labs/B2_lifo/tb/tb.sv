`timescale 10 ps / 10 ps

module tb;

localparam CLK_HALF_PERIOD = 5;
localparam DWIDTH = 8,
           AWIDTH = 8;

logic              clk_i;
logic              srst_i;

logic              wrreq_i;
logic              rdreq_i;
logic [DWIDTH-1:0] data_i;

logic [DWIDTH-1:0] q_o;
logic              empty_o;
logic              full_o;
logic [AWIDTH:0]   usedw_o;


lifo #(
	.AWIDTH  ( AWIDTH  ),
	.DWIDTH  ( DWIDTH  )
) i_lifo (
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
		data_i  = 5;
		repeat (5) @( posedge clk_i );


		// Test sequence from reference work example
		wrreq_i = 1'b1;
		data_i = 'h3A;
		@( posedge clk_i );
		wrreq_i = 0;

		rdreq_i = 1'b1;
		@( posedge clk_i );
		rdreq_i = 0;

		wrreq_i = 1'b1;
		data_i = 'hAE;
		@( posedge clk_i );
		data_i = 'h02;
		@( posedge clk_i );
		data_i = 'hBC;
		@( posedge clk_i );
		wrreq_i = 0;

		rdreq_i = 1'b1;
		@( posedge clk_i );
		rdreq_i = 0;

		wrreq_i = 1'b1;
		data_i = 'h6D;
		@( posedge clk_i );
		data_i = 'h11;
		@( posedge clk_i );
		wrreq_i = 0;

		rdreq_i = 1'b1;
		repeat (4) @( posedge clk_i );
		rdreq_i = 0;
		@( posedge clk_i );


		repeat (259)
			begin
				wrreq_i = 1'b1;
				data_i = data_i + 1;
				@( posedge clk_i );
				wrreq_i = 0;
			end

		repeat (5) @( posedge clk_i );

		repeat (259)
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
