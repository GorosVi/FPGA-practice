module TOP #(
	parameter DATA_WIDTH = 8
) (
input  wire                   clk_i,
input  wire                   srst_i,
input  logic [DATA_WIDTH-1:0] data_i,
output logic [DATA_WIDTH-1:0] data_left_o,
output logic [DATA_WIDTH-1:0] data_right_o
);

logic [DATA_WIDTH-1:0] data_left;
logic [DATA_WIDTH-1:0] data_right;


priority_encoder #(
	.WIDTH        ( DATA_WIDTH )
	) i_priority_encoder (
	.clk_i        ( clk_i      ),
	.srst_i       ( srst_i     ),
	.data_i       ( data_i     ),
	.data_left_o  ( data_left  ),
	.data_right_o ( data_right )
);


always_ff @( posedge clk_i )
	begin
		data_left_o  <= data_left;
		data_right_o <= data_right;
	end


endmodule
