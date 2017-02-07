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

localparam ARRAY_SIZE = ( 2 ** AWIDTH - 1 );

reg   [DWIDTH-1:0] mem [ARRAY_SIZE:0];

enum logic [1:0] { RECEIVE_S,
                   SORTING_S,
                   OUTPUT_S } state, state_next;

logic[AWIDTH-1:0] out_read_ptr;
logic[DWIDTH-1:0] out_read_data;

logic sorting_ok;


always_ff @( posedge clk_i )
	begin : FSM_state_assign
		if( srst_i )
			begin
			 state <= RECEIVE_S;
			end
		else
			begin
				state <= state_next;
			end
	end

always_comb
	begin : FSM_state_next
		state_next = state;

		case( state )

			RECEIVE_S :
				if( eop_i )
					state_next = SORTING_S;

			SORTING_S :
				if( sorting_ok )
					state_next = OUTPUT_S;

			OUTPUT_S :
				if( eop_o )
					state_next = RECEIVE_S;

			default :
					state_next = RECEIVE_S;

		endcase
	end


logic[AWIDTH-1:0] input_words_count;
logic[AWIDTH-1:0] write_ptr, write_ptr_new;

always_comb
	begin
		if( val_i && ( state == RECEIVE_S ) )
			if( sop_i )
				write_ptr_new = 0;
			else
				write_ptr_new = write_ptr + 1'b1;
		else
			write_ptr_new = write_ptr;
	end

always_ff @( posedge clk_i )
	begin
		if( srst_i )
			write_ptr <= 0;
		else
			write_ptr <= write_ptr_new;
	end

assign input_words_count = write_ptr;


logic[AWIDTH-1:0] min_read_ptr,
                  max_read_ptr;
logic[DWIDTH-1:0] min_read_data,
                  max_read_data;
logic data_swap;

always_ff @( posedge clk_i )
	begin
		if( state == SORTING_S )
			begin
				if( min_read_ptr == max_read_ptr - 1'b1 )
					begin
						min_read_ptr <= 0;
						max_read_ptr <= max_read_ptr - 1;
					end
				else
					min_read_ptr <= min_read_ptr + 1'b1;
			end
		else
			begin
				min_read_ptr <= '0;
				max_read_ptr <= write_ptr_new; //input_words_count;
			end
	end

always_comb
	begin
		if( ( state == SORTING_S ) && ( min_read_data > max_read_data ) )
			data_swap <= 1'b1;
		else
			data_swap <= 0;

		if( state == SORTING_S )
			sorting_ok <= ( max_read_ptr == 0 );
		else
			sorting_ok <= 0;
	end


logic [AWIDTH-1:0] mem_ptr;

always_comb
	begin : memory_read_operations
		mem_ptr = 'x;
		min_read_data = 'x;
		max_read_data = 'x;
		out_read_data = 'x;
		if( state == SORTING_S )
			begin
				min_read_data = mem[min_read_ptr];
				max_read_data = mem[max_read_ptr];
			end
		else if( state == OUTPUT_S )
			out_read_data = mem[out_read_ptr];
	end

always_ff @( posedge clk_i )
	begin : memory_write_operations
		if( val_i && ( state == RECEIVE_S ) )
			mem[write_ptr_new] <= data_i;
		else if( data_swap && ( state == SORTING_S ) )
			begin
				mem[min_read_ptr] <= max_read_data;
				mem[max_read_ptr] <= min_read_data;
			end
	end


always_ff @( posedge clk_i )
	begin
		if( srst_i )
			out_read_ptr <= 0;
		else
			if( state == OUTPUT_S )
				if( out_read_ptr <= input_words_count )
					begin
						out_read_ptr <= out_read_ptr + 1'b1;
						data_o <= out_read_data;
					end
				else
					out_read_ptr <= 0;
	end

always_ff @( posedge clk_i )
	begin
		if( ( state_next == OUTPUT_S ) && ( out_read_ptr == 1'b0 ) )
			sop_o <= 1'b1;
		else
			sop_o <= 0;

		if( ( state_next == OUTPUT_S ) && ( out_read_ptr == input_words_count ) )
			eop_o <= 1'b1;
		else
			eop_o <= 0;

		if( ( state_next == OUTPUT_S ) && ( out_read_ptr <= input_words_count ) )
			val_o <= 1'b1;
		else
			val_o <= 0;

		if( ( state_next == SORTING_S ) || ( state_next == OUTPUT_S ) && ( out_read_ptr <= input_words_count ) )
			busy_o <= 1'b1;
		else
			busy_o <= 0;
	end


endmodule
