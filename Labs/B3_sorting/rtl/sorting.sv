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

logic sorting_ok;


localparam ARRAY_SIZE = ( 2 ** AWIDTH - 1 );

reg   [DWIDTH-1:0] mem [ARRAY_SIZE:0];

enum logic [1:0] { RECEIVE_S,
                   SORTING_S,
                   OUTPUT_S } state, state_next;


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
				begin
					if( eop_i )
						begin
							state_next = SORTING_S;
						end
				end
			SORTING_S :
				begin
					if( sorting_ok )
						begin
							state_next = OUTPUT_S;
						end
				end
			OUTPUT_S :
				begin
					if( eop_o )
						begin
							state_next = RECEIVE_S;
						end
				end

			default :
				begin
					state_next = RECEIVE_S;
				end
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

always_ff @( posedge clk_i )
	begin
		if( val_i )
			mem[write_ptr_new] <= data_i;
	end


logic[AWIDTH-1:0] max_read_ptr, max_read_ptr_new,
                  min_read_ptr, min_read_ptr_new,
                  max_sorted_addr,
                  min_sorted_addr;

logic[DWIDTH-1:0] min_read_actual_data,
                  max_read_actual_data,
                  max_read_prev_data,
                  min_read_prev_data,
                  min_write_data,
                  max_write_data;

always_ff @( posedge clk_i )
	begin
		if( state == RECEIVE_S )
			begin
				max_sorted_addr <= input_words_count;
				min_sorted_addr <= '0;
				max_read_ptr <= input_words_count;
				min_read_ptr <= '0;
			end
		if( state == SORTING_S )
			if( min_read_ptr == min_sorted_addr )
				begin
					min_read_prev_data <= min_read_actual_data;
					min_read_ptr  <= min_read_ptr + 1'b1;
				end
			else
				if( min_read_ptr <= max_sorted_addr )
					begin
						min_read_prev_data <= min_read_actual_data;
						min_read_ptr  <= min_read_ptr + 1'b1;
						data_o <= min_read_actual_data;
				end

	end

always_comb
	begin
		if( state == SORTING_S )
			min_read_actual_data = mem[min_read_ptr];
		else
			min_read_actual_data = 0;

		if( state == SORTING_S )
			sorting_ok = ( min_read_ptr == max_sorted_addr ) ? ( 1 ) : ( 0 );
		else
			sorting_ok = 0;
	end




logic[AWIDTH-1:0] read_ptr;

always_ff @( posedge clk_i )
	begin
		if( srst_i )
			read_ptr <= 0;
		else
			if( state == OUTPUT_S )
				if( read_ptr <= input_words_count )
					begin
						read_ptr <= read_ptr + 1'b1;
						//data_o <= mem[read_ptr];
					end
				else
					read_ptr <= 0;
	end

always_ff @( posedge clk_i )
	begin
		if( ( state == OUTPUT_S ) && ( read_ptr == 1'b0 ) )
			sop_o <= 1'b1;
		else
			sop_o <= 0;

		if( ( state == OUTPUT_S ) && ( read_ptr == input_words_count ) )
			eop_o <= 1'b1;
		else
			eop_o <= 0;

		if( ( state == OUTPUT_S ) && ( read_ptr <= input_words_count ) )
			val_o <= 1'b1;
		else
			val_o <= 0;
	end



endmodule
