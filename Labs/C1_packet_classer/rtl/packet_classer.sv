module packet_classer(
	input  wire         clk_i,
	input  wire         srst_i,

// Avalon-MM Slave (csr interface)
	output logic        csr_waitrequest_o,
	input  wire  [1:0]  csr_address_i,
	input  wire         csr_write_i,
	input  wire  [31:0] csr_writedata_i,
	input  wire         csr_read_i,
	output logic [31:0] csr_readdata_o,
	output logic        csr_readdatavalid_o,

// Avalon-Streaming sink
	output logic        ast_ready_o,
	input  wire  [63:0] ast_data_i,
	input  wire         ast_valid_i,
	input  wire         ast_startofpacket_i,
	input  wire         ast_endofpacket_i,
	input  wire  [2:0]  ast_empty_i,

// Avalon-Streaming source
	input  wire         ast_ready_i,
	output logic [63:0] ast_data_o,
	output logic        ast_valid_o,
	output logic        ast_startofpacket_o,
	output logic        ast_endofpacket_o,
	output logic [2:0]  ast_empty_o,
	output logic        ast_channel_o
);

reg [2:0] [31:0] searched_data_reg;

localparam PPLN_LEN = 3; // Set pipelining length
reg [PPLN_LEN-1 : 0] [63:0] data_reg;
reg [PPLN_LEN-1 : 0] [2:0]  empty_reg;
reg [PPLN_LEN-1 : 0]        startofpacket_reg;
reg [PPLN_LEN-1 : 0]        endofpacket_reg;
reg [PPLN_LEN-1 : 0]        valid_reg;
reg [PPLN_LEN-1 : 0]        marking_flag_reg;

int index_reset;
always_ff @( posedge clk_i )
	if( srst_i )
		for( index_reset = 0; index_reset < PPLN_LEN; index_reset++ )
			begin
				data_reg          [i] <= '0;
				empty_reg         [i] <= '0;
				startofpacket_reg [i] <= '0;
				endofpacket_reg   [i] <= '0;
				valid_reg         [i] <= '0;
				marking_flag_reg  [i] <= '0;
			end
	else
		begin
			data_reg          [0] <= ast_data_i;
			empty_reg         [0] <= ast_empty_i;
			startofpacket_reg [0] <= ast_startofpacket_i;
			endofpacket_reg   [0] <= ast_endofpacket_i;
			valid_reg         [0] <= ast_valid_i;
			marking_flag_reg  [0] <= '0;
			for( index_reset = 1; index_reset < PPLN_LEN; index_reset++ )
				begin
					data_reg          [i] <= data_reg          [i-1];
					empty_reg         [i] <= empty_reg         [i-1];
					startofpacket_reg [i] <= startofpacket_reg [i-1];
					endofpacket_reg   [i] <= endofpacket_reg   [i-1];
					valid_reg         [i] <= valid_reg         [i-1];
					marking_flag_reg  [i] <= marking_flag_reg  [i-1];
				end
		end

function test_match;
	input [PPLN_LEN-1 : 0] [63:0] f_data_reg;
	input [2:0] [31:0] f_search_reg;
	input int skip_bytes;
	logic f_result;
			f_result[i] = ""
endfunction
endmodule
