module TOP #(
	parameter DWIDTH = 8,
	          AWIDTH = 4
)(
	input  wire              clk_i,
	input  wire              srst_i,

	input  wire               sop_i,
	input  wire               eop_i,
	input  wire               val_i,
	input  wire  [DWIDTH-1:0] data_i,

	output logic              sop_o,
	output logic              eop_o,
	output logic              val_o,
	output logic [DWIDTH-1:0] data_o,

	output logic              busy_o
);


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


endmodule
