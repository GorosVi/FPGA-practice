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




logic[AWIDTH-1:0] max_read_ptr,
                  min_read_ptr,
                  max_sorted_addr,
                  min_sorted_addr;

logic[DWIDTH-1:0] min_read_data,
                  max_read_data,
                  min_write_data,
                  max_write_data;

logic data_swap;

always_ff @( posedge clk_i )
	begin
		if( state == SORTING_S )
			begin
				if( min_read_ptr == min_sorted_addr )
					min_read_ptr  <= min_read_ptr + 1'b1;
				else if( min_read_ptr == max_sorted_addr)
					begin
						max_sorted_addr <= max_sorted_addr - 1;
						max_read_ptr <= max_read_ptr - 1;
						min_read_ptr <= 0;
					end
				else
					min_read_ptr  <= min_read_ptr + 1'b1;
			end
		else
			begin
				max_sorted_addr <= write_ptr_new;// input_words_count;
				max_read_ptr <= write_ptr_new;//input_words_count;
				min_sorted_addr <= '0;
				min_read_ptr <= '0;
			end

		// if( state == SORTING_S )
		// 	sorting_ok <= ( min_read_ptr == max_sorted_addr ) ? ( 1 ) : ( 0 );
		// else
			sorting_ok <= 0;

	end

always_comb
	begin
		if( ( state == SORTING_S ) && ( min_read_data > max_read_data ) )
			data_swap <= 1'b1;
		else
			data_swap <= 0;
	end



assign busy_o = data_swap;
assign data_o = min_read_data;
always_comb
	begin : memory_read_operations
		if( state == SORTING_S )
			begin
				min_read_data = mem[min_read_ptr];
				max_read_data = mem[max_read_ptr];
			end
		else
			begin
				min_read_data = 'x;
				max_read_data = 'x;
			end
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
