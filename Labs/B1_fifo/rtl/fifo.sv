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
logic [AWIDTH  :0] read_ptr, read_ptr_base, write_ptr;


always_ff @( posedge clk_i )
	begin : fifo_pointer_control
		if( srst_i )
			begin
				read_ptr_base <= '0;
				write_ptr     <= '0;
			end
		else
			begin
				read_ptr_base <= read_ptr;
				write_ptr     <= ( wrreq_i ) ? ( write_ptr + 1'b1 ) : ( write_ptr );
			end
	end

assign read_ptr = ( rdreq_i ) ? ( read_ptr_base  + 1'b1 ) : ( read_ptr_base );

always_ff @( posedge clk_i )
	begin : fifo_memory_operations
		// Write data
		if( wrreq_i && ~full_o )
			mem[ write_ptr[ AWIDTH-1:0 ] ] <= data_i;
		// Read data
		if( rdreq_i && ~empty_o || ( SHOWAHEAD == "ON" ) )
			q_o <= mem[ read_ptr[ AWIDTH-1:0 ] ];
	end


always_ff @( posedge clk_i )
	begin : fifo_output_control
		usedw_o <= write_ptr - read_ptr;
		empty_o <= ( write_ptr == read_ptr );
		full_o  <= ( ( write_ptr - read_ptr ) == ( 2 ** ( AWIDTH ) ) );
	end


endmodule
