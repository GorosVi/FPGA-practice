module TOP (
	input  wire         clk_i,
	input  wire         srst_i,

	input  wire  [2:0]  cmd_type_i,
	input  wire  [15:0] cmd_data_i,
	input  wire         cmd_valid_i,


	output logic red_o,
	output logic yellow_o,
	output logic green_o
);

	logic csr_waitrequest_o;
	wire [1:0] csr_address_i;
	wire csr_write_i;
	wire [31:0] csr_writedata_i;
	wire csr_read_i;
	logic [31:0] csr_readdata_o;
	logic csr_readdatavalid_o;
	logic ast_ready_o;
	wire [63:0] ast_data_i;
	wire ast_valid_i;
	wire ast_startofpacket_i;
	wire ast_endofpacket_i;
	wire [2:0] ast_empty_i;
	wire ast_ready_i;
	logic [63:0] ast_data_o;
	logic ast_valid_o;
	logic ast_startofpacket_o;
	logic ast_endofpacket_o;
	logic [2:0] ast_empty_o;
	logic ast_channel_o;
packet_classer i_packet_classer (
	.clk_i              (clk_i              ),
	.srst_i             (srst_i             ),

	.csr_waitrequest_o  (csr_waitrequest_o  ),
	.csr_address_i      (csr_address_i      ),
	.csr_write_i        (csr_write_i        ),
	.csr_writedata_i    (csr_writedata_i    ),
	.csr_read_i         (csr_read_i         ),
	.csr_readdata_o     (csr_readdata_o     ),
	.csr_readdatavalid_o(csr_readdatavalid_o),

	.ast_ready_o        (ast_ready_o        ),
	.ast_data_i         (ast_data_i         ),
	.ast_valid_i        (ast_valid_i        ),
	.ast_startofpacket_i(ast_startofpacket_i),
	.ast_endofpacket_i  (ast_endofpacket_i  ),
	.ast_empty_i        (ast_empty_i        ),
	.ast_ready_i        (ast_ready_i        ),

	.ast_data_o         (ast_data_o         ),
	.ast_valid_o        (ast_valid_o        ),
	.ast_startofpacket_o(ast_startofpacket_o),
	.ast_endofpacket_o  (ast_endofpacket_o  ),
	.ast_empty_o        (ast_empty_o        ),
	.ast_channel_o      (ast_channel_o      )
);



endmodule
