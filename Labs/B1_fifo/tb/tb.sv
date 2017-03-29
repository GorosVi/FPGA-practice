`timescale 10 ps / 10 ps

module tb;

localparam CLK_HALF_PERIOD = 5;
localparam SHOWAHEAD = "OFF";
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
logic [AWIDTH  :0] usedw_o;


fifo #(
	.SHOWAHEAD ( SHOWAHEAD ),
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


logic [DWIDTH-1:0] tb_prev_output;

initial
	begin : test_sequence_generator

		wrreq_i = 0;
		rdreq_i = 0;
		data_i = 0;
		repeat (3) @( posedge clk_i );
		// Test sequence from lecture slides
		wrreq_i = 1'b1;
		@( posedge clk_i );
		data_i = data_i + 1;
		rdreq_i = 1;
		@( posedge clk_i );
		data_i = data_i + 1;
		@( posedge clk_i );
		// rdreq_i = 0;
		data_i = data_i + 1;
		@( posedge clk_i );
		wrreq_i = 0;
		@( posedge clk_i );
		rdreq_i = 0;
		@( posedge clk_i );
		@( posedge clk_i );
		rdreq_i = 0;

		repeat (3) @( posedge clk_i );

		tb_prev_output = q_o;

		// Controlled test sequence
		tb_noread();
		tb_nowrite();
		repeat (2) @( posedge clk_i );
		tb_assert_no_showahead(tb_prev_output, 'd0, 1'b0, 1'b1);

		tb_write  ( 'hEE );
		tb_noread ();
		@( posedge clk_i );
		tb_assert_no_showahead(tb_prev_output, 'd0, 1'b0, 1'b1);

		tb_write  ( 'h01 );
		tb_noread ();
		@( posedge clk_i );
		tb_assert_no_showahead(tb_prev_output, 'd1, 1'b0, 1'b0);

		tb_write  ( 'h33 );
		tb_noread ();
		@( posedge clk_i );
		tb_assert_no_showahead(tb_prev_output, 'd2, 1'b0, 1'b0);

		tb_write  ( 'h7B );
		tb_noread ();
		@( posedge clk_i );
		tb_assert_no_showahead(tb_prev_output, 'd3, 1'b0, 1'b0);

		tb_write  ( 'hDA );
		tb_read ();
		@( posedge clk_i );
		tb_assert_no_showahead(tb_prev_output, 'd4, 1'b1, 1'b0);

		tb_nowrite ();
		tb_read ();
		@( posedge clk_i );
		tb_assert_no_showahead('hEE, 'd4, 1'b1, 1'b0);

		tb_nowrite ();
		tb_read ();
		@( posedge clk_i );
		tb_assert_no_showahead('h01, 'd3, 1'b0, 1'b0);

		tb_write  ( 'hCF );
		tb_read ();
		@( posedge clk_i );
		tb_assert_no_showahead('h33, 'd2, 1'b0, 1'b0);

		tb_write  ( 'hAA );
		tb_read ();
		@( posedge clk_i );
		tb_assert_no_showahead('h7B, 'd2, 1'b0, 1'b0);

		tb_write  ( 'hBB );
		tb_noread ();
		@( posedge clk_i );
		tb_assert_no_showahead('hDA, 'd2, 1'b0, 1'b0);

		tb_write  ( 'hCC );
		tb_noread ();
		@( posedge clk_i );
		tb_assert_no_showahead('hDA, 'd3, 1'b0, 1'b0);

		tb_nowrite ();
		tb_read ();
		@( posedge clk_i );
		tb_assert_no_showahead('hDA, 'd4, 1'b1, 1'b0);

		tb_nowrite ();
		tb_read ();
		@( posedge clk_i );
		tb_assert_no_showahead('hCF, 'd3, 1'b0, 1'b0);

		tb_nowrite ();
		tb_read ();
		@( posedge clk_i );
		tb_assert_no_showahead('hAA, 'd2, 1'b0, 1'b0);

		tb_nowrite ();
		tb_read ();
		@( posedge clk_i );
		tb_assert_no_showahead('hBB, 'd1, 1'b0, 1'b0);

		tb_nowrite ();
		tb_noread ();
		@( posedge clk_i );
		tb_assert_no_showahead('hCC, 'd0, 1'b0, 1'b1);

		repeat (3) @( posedge clk_i );


		$stop;
	end


task tb_write;
	input [ DWIDTH-1 : 0 ] tb_data;
	begin
		wrreq_i = 1'b1;
		data_i = tb_data;
	end
endtask

task tb_read;
	rdreq_i = 1;
endtask

task tb_nowrite;
	wrreq_i = 0;
endtask

task tb_noread;
	rdreq_i = 0;
endtask

task tb_assert_no_showahead;
	input [DWIDTH-1:0] tb_data_out;
	input integer tb_usedw_out;
	input tb_full_out;
	input tb_empty_out;
	if( SHOWAHEAD != "ON" )
		begin
			assert ( q_o     == tb_data_out  ) else $error ("Error: q_o     not same as reference in mode showahead == OFF (%b, %b)", q_o,     tb_data_out);
			assert ( usedw_o == tb_usedw_out ) else $error ("Error: usedw_o not same as reference in mode showahead == OFF (%d, %d)", usedw_o, tb_usedw_out);
			assert ( full_o  == tb_full_out  ) else $error ("Error: full_o  not same as reference in mode showahead == OFF (%d, %d)", full_o,  tb_full_out);
			assert ( empty_o == tb_empty_out ) else $error ("Error: empty_o not same as reference in mode showahead == OFF (%d, %d)", empty_o, tb_empty_out);
		end
endtask

endmodule
