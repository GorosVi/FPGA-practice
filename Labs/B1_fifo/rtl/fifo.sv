module fifo #(
	parameter AWIDTH    = 8,
	          DWIDTH    = 8,
	          SHOWAHEAD = "OFF"
)(
	input  wire              clk_i,
	input  wire              srst_i,

	input  wire  [DWIDTH-1:0] data_i,
	input  wire               wrreq_i,
	input  wire               rdreq_i,

	output logic [DWIDTH-1:0] q_o,
	output logic              empty_o,
	output logic              full_o,
	output logic [AWIDTH-1:0] usedw_o
);

localparam ARRAY_SIZE = ( 2 ** AWIDTH - 1 );

reg   [DWIDTH-1:0] mem [ARRAY_SIZE:0];
logic [AWIDTH  :0] used_width;
logic [AWIDTH  :0] read_ptr, read_ptr_new,
                   write_ptr, write_ptr_new;


always_ff @( posedge clk_i )
	begin
		if( srst_i )
			begin
				read_ptr  <= 0;
				write_ptr <= 0;
				q_o       <= 0;
			end
		else
			begin
				if( wrreq_i )
					begin
						mem[write_ptr] <= data_i;
						write_ptr      <= write_ptr_new;
					end
				if( rdreq_i )
					begin
						q_o       <= mem[read_ptr];
						read_ptr  <= read_ptr_new;
					end
				q_o       <= mem[read_ptr];
			end
	end


always_comb
	begin
		used_width = write_ptr - read_ptr;
		usedw_o = used_width;

		empty_o = ( used_width == 0 );
		full_o  = ( used_width == 2 ** AWIDTH );

		read_ptr_new  = ( ~empty_o ) ? ( read_ptr + 1'b1 ):
		                               ( read_ptr );
		write_ptr_new = ( ~full_o )  ? ( write_ptr + 1'b1 ):
		                               ( write_ptr );
	end


endmodule
