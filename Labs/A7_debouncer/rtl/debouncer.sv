module debouncer #(
	parameter CLK_FREQ_MHZ   = 20,
	parameter GLITCH_TIME_NS = 200
)(
	input  wire  clk_i,
	input  wire  srst_i,
	input  wire  key_i,
	output logic key_pressed_stb_o
);


localparam GLITCH_TIME_CLK = GLITCH_TIME_NS * CLK_FREQ_MHZ / ( 10 ** 3 );
localparam TIMEOUT_COUNTER_WIDTH = $clog2(GLITCH_TIME_CLK);
initial begin
  $display("Debouncer: For counter of %d clock edges used %d-bit counter.", GLITCH_TIME_CLK, TIMEOUT_COUNTER_WIDTH + 1 );
	assert (GLITCH_TIME_CLK <= 0) $warning("Calculated glitch time is less than one clock period. Module behavior may differ from the intended.");
end

logic [1:0] key_input_pipeline;
logic [ TIMEOUT_COUNTER_WIDTH : 0 ] timeout_counter;
logic [ TIMEOUT_COUNTER_WIDTH : 0 ] timeout_counter_next;

enum logic [1:0] { STAY_PRESSED_S,
                   STAY_RELEASED_S,
                   TIMEOUT_PRESSED_S,
                   TIMEOUT_RELEASED_S } state, state_next;

logic key_input_pressed;


always_ff @(posedge clk_i)
	begin : pipeline_key_input
		key_input_pipeline <= { key_input_pipeline[0], key_i };
		// Converting input to (pressed == high) state
		key_input_pressed  <=   ~key_input_pipeline[1];
	end


always_ff @(posedge clk_i)
	begin : FSM_key
		if ( srst_i )
			begin
				timeout_counter = 0;
				// Setting module state according input state to prevent
				// 	 glitch after power-on
				if ( key_input_pressed == 1'b1 )
					state = STAY_PRESSED_S;
				else
					state = STAY_RELEASED_S;
			end
		else
			begin
				state           <= state_next;
				timeout_counter <= timeout_counter_next;
			end
	end


always_comb
	begin : FSM_key_next
		timeout_counter_next = 0;
		case ( state )
			STAY_PRESSED_S:
				begin
					if ( key_input_pressed == 0 )
						begin
							timeout_counter_next = GLITCH_TIME_CLK[ TIMEOUT_COUNTER_WIDTH : 0 ];
							state_next = TIMEOUT_RELEASED_S;
						end
					else
						state_next = STAY_PRESSED_S;
				end

			STAY_RELEASED_S:
				begin
					if ( key_input_pressed == 1 )
						begin
							timeout_counter_next = GLITCH_TIME_CLK[ TIMEOUT_COUNTER_WIDTH : 0 ];
							state_next = TIMEOUT_PRESSED_S;
						end
					else
						state_next = STAY_RELEASED_S;
				end

			TIMEOUT_PRESSED_S:
				begin
					if ( timeout_counter > 0 )
						begin
							timeout_counter_next = timeout_counter - 1'b1;
							state_next = TIMEOUT_PRESSED_S;
						end
					else
						state_next = STAY_PRESSED_S;
				end

			TIMEOUT_RELEASED_S:
				begin
					if ( timeout_counter > 0 )
						begin
							timeout_counter_next = timeout_counter - 1'b1;
							state_next = TIMEOUT_RELEASED_S;
						end
					else
						state_next = STAY_RELEASED_S;
				end

			default:
				begin
					state_next = STAY_RELEASED_S;
				end
		endcase
	end


always_comb
	begin : FSM_output
		// Strobe event to output when state is in transition to STAY_PRESSED_S and counter loaded to Timeout value
		if ( ( state == TIMEOUT_PRESSED_S ) && ( timeout_counter == GLITCH_TIME_CLK[ TIMEOUT_COUNTER_WIDTH : 0 ] ) )
			key_pressed_stb_o = 1'b1;
		else
			key_pressed_stb_o = 1'b0;
	end


endmodule
