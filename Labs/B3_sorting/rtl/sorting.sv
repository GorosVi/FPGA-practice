module sorting #(
	parameter AWIDTH    = 8,
	          DWIDTH    = 8
)(
	input  wire               clk_i,
	input  wire               srst_i,

	input  wire  [DWIDTH-1:0] data_i,
	input  wire               sop_i,
	input  wire               eop_i,
	input  wire               val_i,

	output logic [DWIDTH-1:0] data_o,
	output logic              sop_o,
	output logic              eop_o,
	output logic              val_o,

	output logic              busy_o
);

enum logic [1:0] { RECEIVE_S,
                   SORTING_S,
                   OUTPUT_S   } state, state_next;

logic sort_finished;

always_ff @( posedge clk_i )
	state <= ( srst_i ) ? ( RECEIVE_S ) : ( state_next );

always_comb
	begin : FSM_state_next
		case( state )
			RECEIVE_S : state_next = ( eop_i         ) ? ( SORTING_S ) : ( state );
			SORTING_S : state_next = ( sort_finished ) ? ( OUTPUT_S  ) : ( state );
			OUTPUT_S  : state_next = ( eop_o         ) ? ( RECEIVE_S ) : ( state );
			default   : state_next = RECEIVE_S;
		endcase
	end


logic[AWIDTH-1:0] input_write_ptr;
logic[AWIDTH-1:0] input_words_count;
assign input_words_count = input_write_ptr;

always_ff @( posedge clk_i )
	if( srst_i )
		input_write_ptr <= '0;
	else
		if( val_i && ( state == RECEIVE_S ) )
			input_write_ptr <= input_write_ptr + 1'b1;
		// Bad hook on state_next
		else if( ( state == OUTPUT_S ) && ( state_next == RECEIVE_S ) )
			input_write_ptr <= '0;
		else
			input_write_ptr <= input_write_ptr;


logic[AWIDTH-1:0] sort_ptr_start, sort_ptr_end, sort_ptr_mem;
logic[DWIDTH-1:0] sort_data_a,    sort_data_b;
logic sort_swap_op;

// This ptr is needed to be deleted. But new increases after comparsion and breaks the data.
assign sort_ptr_mem = ( sort_swap_op ) ? ( sort_ptr_start ) : ( sort_ptr_start + 1'b1 );

always_ff @( posedge clk_i )
	// Check val_i to skip one clock cycle after data reading
	if( ( state == SORTING_S ) && ~val_i )
		if ( sort_swap_op )
			sort_ptr_start <= sort_ptr_start;
		else
			if( sort_ptr_start < sort_ptr_end - 1'b1 )
				sort_ptr_start <= sort_ptr_start + 1'b1;
			else
				begin
					sort_ptr_end <= sort_ptr_end - 1'b1;
					sort_ptr_start <= '0;
				end
	else
		begin
			sort_ptr_start <= '0;
			sort_ptr_end <= input_words_count;
		end

always_ff @( posedge clk_i )
	begin
		// Can not work in data sets less than 2 bytes
		if( ( state == SORTING_S ) && ( sort_ptr_end <= 1'b1 ) )
			sort_finished <= 1'b1;
		else
			sort_finished <= 1'b0;
	end

always_comb
	// Check val_i to skip one clock cycle after data reading
	if( ( state == SORTING_S ) && ~val_i )
		if( sort_data_a > sort_data_b )
			sort_swap_op <= 1'b1;
		else
			sort_swap_op <= '0;
	else
		sort_swap_op <= '0;

// After sort execution mem_ptr_a should be set to 0, to ensure properly output work
logic[AWIDTH-1:0] out_read_ptr, out_read_ptr_new;

always_ff @( posedge clk_i )
	if( srst_i )
		out_read_ptr <= '0;
	else
	// Bad hook to state_next
		if( state_next == OUTPUT_S )
			out_read_ptr <= out_read_ptr + 1'b1;
		else
			out_read_ptr <= '0;


logic             mem_wren_a,  mem_wren_b;
logic[AWIDTH-1:0] mem_ptr_a,   mem_ptr_b;
logic[DWIDTH-1:0] mem_data_a,  mem_data_b,
                  mem_q_a,     mem_q_b;

always_comb
	begin : memory_pointer_control
		mem_wren_a  = '0;
		mem_wren_b  = '0;
		mem_ptr_a   = 'x;
		mem_ptr_b   = 'x;
		mem_data_a  = 'x;
		mem_data_b  = 'x;
		case( state )
			RECEIVE_S :
				begin
					mem_wren_a = '1;
					mem_ptr_a = input_write_ptr;
					mem_data_a = data_i;
				end
			SORTING_S :
				begin
					mem_wren_a = sort_swap_op;
					mem_wren_b = sort_swap_op;
					mem_ptr_a = sort_ptr_mem - 1'b1;
					mem_ptr_b = sort_ptr_mem;
					mem_data_a = sort_data_b;
					mem_data_b = sort_data_a;
				end
			OUTPUT_S :
				begin
					mem_ptr_a = out_read_ptr;
				end
			default : ;
		endcase
	end

always_comb
	begin : mem_output_mappings
		sort_data_a = mem_q_a;
		sort_data_b = mem_q_b;

		if( state == OUTPUT_S )
			data_o = mem_q_a;
		else
			data_o = 'x;
	end


true_dual_port_ram_single_clock #(
	.DATA_WIDTH ( DWIDTH ),
	.ADDR_WIDTH ( AWIDTH )
) i_true_dual_port_ram_single_clock (
	.data_a ( mem_data_a ),
	.data_b ( mem_data_b ),
	.addr_a ( mem_ptr_a  ),
	.addr_b ( mem_ptr_b  ),
	.we_a   ( mem_wren_a ),
	.we_b   ( mem_wren_b ),
	.clk    ( clk_i      ),
	.q_a    ( mem_q_a    ),
	.q_b    ( mem_q_b    )
);


always_comb
	begin
		// Triggers on value == 1, so first byte was already acquired
		if( ( state == OUTPUT_S ) && ( out_read_ptr == 1'b1 ) )
			sop_o = 1'b1;
		else
			sop_o = 0;

		if( ( state == OUTPUT_S ) && ( out_read_ptr == input_words_count ) )
			eop_o = 1'b1;
		else
			eop_o = 0;

		if( ( state == OUTPUT_S ) && ( out_read_ptr <= input_words_count ) )
			val_o = 1'b1;
		else
			val_o = 0;

		if( ( state == SORTING_S ) || ( state == OUTPUT_S ) )
			busy_o = 1'b1;
		else
			busy_o = 0;
	end


endmodule