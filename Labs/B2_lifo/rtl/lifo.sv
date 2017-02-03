module lifo #(
	parameter AWIDTH    = 8,
	          DWIDTH    = 8
)(
	input  wire               clk_i,
	input  wire               srst_i,

	input  wire  [DWIDTH-1:0] data_i,
	input  wire               wrreq_i,
	input  wire               rdreq_i,

	output logic [DWIDTH-1:0] q_o,
	output logic              empty_o,
	output logic              full_o,
	output logic [AWIDTH  :0] usedw_o
);

localparam ARRAY_SIZE = ( 2 ** AWIDTH - 1 );

reg   [DWIDTH-1:0] mem [ARRAY_SIZE:0];
logic [AWIDTH  :0] write_ptr, read_ptr;


always_ff @( posedge clk_i )
	begin
		if( srst_i )
			begin
				write_ptr <= '0;
				read_ptr  <= '0 - 1'b1;
				q_o       <= '0;
			end
		else
			if( wrreq_i && ~full_o )
				begin
					mem[write_ptr] <= data_i;
					write_ptr      <= write_ptr + 1'b1;
					read_ptr       <= write_ptr;
				end
			else if( rdreq_i && ~empty_o )
				begin
					q_o       <= mem[read_ptr];
					write_ptr <= write_ptr - 1'b1;
					read_ptr  <= write_ptr - 2'd2;
				end
	end


always_comb
	begin
		usedw_o = write_ptr[AWIDTH:0];
		empty_o = ( write_ptr == 0 );
		full_o  = ( write_ptr == 2 ** AWIDTH );
	end


endmodule
