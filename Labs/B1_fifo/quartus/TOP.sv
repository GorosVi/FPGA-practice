module TOP #(
	parameter DWIDTH = 8,
	          AWIDTH = 8
)(
	input  wire              clk_i,
	input  wire              srst_i,

	input  wire               wrreq_i,
	input  wire               rdreq_i,
	input  wire  [DWIDTH-1:0] data_i,

	output logic [DWIDTH-1:0] q_o,
	output logic              empty_o,
	output logic              full_o,
	output logic [AWIDTH  :0] usedw_o
);


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


endmodule
