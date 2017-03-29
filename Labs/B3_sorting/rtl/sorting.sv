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
                   OUTPUT_S   } state, state_next;

always_ff @( posedge clk_i )
	state = ( srst_i ) ? ( RECEIVE_S ) : ( state_next );

logic sort_finished;

always_comb
	begin : FSM_state_next
		case( state )
			RECEIVE_S : state_next = ( eop_i         ) ? ( SORTING_S ) : ( state );
			SORTING_S : state_next = ( sort_finished ) ? ( OUTPUT_S  ) : ( state );
			OUTPUT_S  : state_next = ( eop_o         ) ? ( RECEIVE_S ) : ( state );
			default   : state_next = RECEIVE_S;
		endcase
	end


logic[AWIDTH-1:0] out_read_ptr;
logic[DWIDTH-1:0] out_read_data;

logic input_read_data;

logic[AWIDTH-1:0] input_write_ptr, input_write_ptr_new;

logic[AWIDTH-1:0] input_words_count;
assign input_words_count = input_write_ptr;

always_ff @( posedge clk_i )
	input_write_ptr <= ( srst_i ) ? ( 0 ) : ( input_write_ptr_new );

always_comb
	if( val_i && ( state == RECEIVE_S ) )
		if ( sop_i )
			input_write_ptr_new = 0;
		else
			input_write_ptr_new = input_write_ptr + 1'b1;
	else
		input_write_ptr_new = input_write_ptr;


logic[AWIDTH-1:0] min_read_ptr,
                  max_read_ptr;
logic[DWIDTH-1:0] min_read_data,
                  max_read_data,
                  min_write_data,
                  max_write_data;
logic sorting_data_swap;

always_ff @( posedge clk_i )
	begin
		if( state == SORTING_S )
			begin
				if( min_read_ptr == max_read_ptr - 1'b1 )
					begin
						min_read_ptr <= 0;
						max_read_ptr <= max_read_ptr - 1'b1;
						min_write_data <= min_read_data;
						max_write_data <= max_read_data;
					end
				else
					begin
						min_read_ptr <= min_read_ptr + 1'b1;
						min_write_data <= min_read_data;
						max_write_data <= max_read_data;
					end
				// sorting_data_swap <= ( min_read_data > max_read_data );
			end
		else
			begin
				min_read_ptr <= '1;// за костыль
				max_read_ptr <= input_write_ptr_new + 1'b1; //input_words_count;
				min_write_data <= 0;
				max_write_data <= 0;
				// sorting_data_swap <= 0;
		end
	end

always_comb
	begin
		sort_finished     = ( max_read_ptr == 0 );
		sorting_data_swap = ( min_read_data > max_read_data );
	end

always_ff @( posedge clk_i )
	begin
		if( srst_i )
			out_read_ptr <= '0;
		else
			if( state == OUTPUT_S )
				out_read_ptr <= out_read_ptr + 1'b1;
			else
				out_read_ptr <= '0;
	end

assign data_o = out_read_data;


logic [AWIDTH-1:0] mem_ptr_a, mem_ptr_b;
logic [DWIDTH-1:0] mem_r_data_a, mem_r_data_b,
                   mem_w_data_a, mem_w_data_b;

logic mem_write_enable_a, mem_write_enable_b;

always_comb
	begin : data_operations
		min_read_data = 'x;
		max_read_data = 'x;
		out_read_data = 'x;
		mem_ptr_a     = '0;
		mem_ptr_b     = '0;
		mem_w_data_a  = '0;
		mem_w_data_b  = '0;
		mem_write_enable_a = 0;
		mem_write_enable_b = 0;

		if(( state == RECEIVE_S ) && val_i )
			begin
				mem_ptr_a = input_write_ptr_new;
				mem_w_data_a = data_i;
				mem_write_enable_a = val_i;
			end
		// else if( state == SORTING_S )
		// 	begin
		// 		// mem_ptr_a = min_read_ptr;
		// 		// mem_ptr_b = max_read_ptr;
		// 		// if( ~sorting_data_swap )
		// 		// 	begin
		// 		// 		min_read_data = mem_r_data_a;
		// 		// 		max_read_data = mem_r_data_b;
		// 		// 	end
		// 		// else
		// 		// 	begin
		// 		// 		// mem_w_data_a = max_write_data;
		// 		// 		// mem_w_data_b = min_write_data;
		// 		// 		// mem_write_enable_a = 1'b1;
		// 		// 		// mem_write_enable_b = 1'b1;
		// 		// 	end
		// 	end
		else if( state == OUTPUT_S )
			begin
				mem_ptr_b = out_read_ptr;
				out_read_data = mem_r_data_b;
			end
	end

always_ff @( posedge clk_i )
	begin : memory_operations
		mem_r_data_a <= mem[mem_ptr_a];
		if( mem_write_enable_a )
			mem[mem_ptr_a] <= mem_w_data_a;

		mem_r_data_b <= mem[mem_ptr_b];
		if( mem_write_enable_b )
			mem[mem_ptr_b] <= mem_w_data_b;
	end


always_ff @( posedge clk_i )
	begin
		// if( ( state_next == OUTPUT_S ) && ( out_read_ptr == 1'b0 ) )
		// 	sop_o <= 1'b1;
		// else
		// 	sop_o <= 0;

		if( ( state_next == OUTPUT_S ) && ( out_read_ptr == input_words_count ) )
			eop_o <= 1'b1;
		else
			eop_o <= 0;

		// if( ( state_next == OUTPUT_S ) && ( out_read_ptr <= input_words_count ) )
		// 	val_o <= 1'b1;
		// else
		// 	val_o <= 0;

		// if( ( state_next == SORTING_S ) || ( state_next == OUTPUT_S ) && ( out_read_ptr <= input_words_count ) )
		// 	busy_o <= 1'b1;
		// else
		// 	busy_o <= 0;
	end


endmodule
