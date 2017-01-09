module prbs_gen (
	output dout,
	input srst,
	input clk
);
reg [2:0] prbs_state;
wire next_state;

always @(posedge clk)
	begin
	if (srst)
		prbs_state <= 3'b111;
	else
		prbs_state <= {prbs_state[1:0], next_state};
	end
	assign next_state = prbs_state[2] ^ prbs_state[1];
	assign dout = next_state;
	
endmodule
