module priority_encoder #(
	parameter WIDTH = 4
)(
	input wire              clk_i,
	input wire              srst_i,
	input wire  [WIDTH-1:0] data_i,
	output wire [WIDTH-1:0] data_left_o,
	output wire [WIDTH-1:0] data_right_o
);

reg [WIDTH-1:0] data_left;
reg [WIDTH-1:0] data_right;

// In this variant result is last triggered expression
always_comb
	begin : left_bit_filter
		data_left = 0;
		for ( int i = 0; i < WIDTH; i++ )
			begin
				if ( data_i[i] == 1'b1 )
					data_left = ( 1'b1 << i );
			end
	end


always_comb
	begin : right_bit_filter
		data_right  = 0;
		for ( int i = ( WIDTH - 1 ); i >= 0; i-- )
			begin
				if ( data_i[i] == 1'b1 )
					data_right = ( 1'b1 << i );
			end
	end


assign data_left_o = data_left;
assign data_right_o = data_right;


endmodule
