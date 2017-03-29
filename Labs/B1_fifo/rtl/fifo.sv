module fifo #(
	parameter AWIDTH    = 8,
	          DWIDTH    = 8,
	          SHOWAHEAD = "OFF"
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
logic [AWIDTH  :0] read_ptr, write_ptr;

logic showahead_mode_on = ( SHOWAHEAD == "ON" );


always_ff @( posedge clk_i )
	begin : fifo_pointer_control
		if( srst_i )
			begin
				write_ptr <= '0;
				read_ptr  <= '0;
			end
		else
			begin
				write_ptr <= ( wrreq_i ) ? ( write_ptr + 1'b1 )
				                         : ( write_ptr );
				read_ptr  <= ( rdreq_i ) ? ( read_ptr  + 1'b1 )
				                         : ( read_ptr );
			end
	end

always_ff @( posedge clk_i )
	begin
		if( wrreq_i )
			mem[ write_ptr[ AWIDTH-1:0 ] ] <= data_i;
		if( rdreq_i || showahead_mode_on )
			q_o <= mem[ read_ptr[ AWIDTH-1:0 ] ];
	end

assign usedw_o = ( write_ptr - read_ptr );
assign full_o  = ( usedw_o   == ( 2 ** ( AWIDTH ) ) );
assign empty_o = ( write_ptr == read_ptr );

endmodule
