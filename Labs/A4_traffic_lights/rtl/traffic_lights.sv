module traffic_lights #(
	parameter BLINK_HALF_PERIOD   = 15'd500,  // (ms)
	          GREEN_BLINKS_NUM    = 3,
	          RED_YELLOW_TIME     = 15'd500,  // (ms)
	          RED_TIME_DEFAULT    = 15'd3000, // (ms)
	          YELLOW_TIME_DEFAULT = 15'd1000, // (ms)
	          GREEN_TIME_DEFAULT  = 15'd3000  // (ms)
)(
	// clock period = 1 ms (1 KHz)
	input  wire         clk_i,
	input  wire         srst_i,

	input  wire  [2:0]  cmd_type_i,
	input  wire  [15:0] cmd_data_i,
	input  wire         cmd_valid_i,

	output logic        red_o,
	output logic        yellow_o,
	output logic        green_o
);

localparam GREEN_BLINK_TIME = GREEN_BLINKS_NUM * BLINK_HALF_PERIOD * 2;

localparam [2:0]
	CMD_ON             = 3'd0,
	CMD_OFF            = 3'd1,
	CMD_OFF_CONTROL    = 3'd2,
	CMD_SET_GREEN_TIME = 3'd3,
	CMD_SET_RED_TIME   = 3'd4,
	CMD_SET_YELOW_TIME = 3'd5;

logic [$clog2(BLINK_HALF_PERIOD)-1:0] blinker_timer;
logic blinker_reset, blinker_output;

enum logic [2:0] { OFF_S,
                   RED_ON_S,
                   RED_YELLOW_ON_S,
                   YELLOW_ON_S,
                   GREEN_ON_S,
                   GREEN_BLINK_S,
                   UNCONTROLLED_S } state, state_next;

logic [15:0] timeout_counter,
             timeout_counter_next,
             red_timeout_value,
             yellow_timeout_value,
             green_timeout_value;


always_ff @(posedge clk_i)
	begin : timeout_presets_control
		if( srst_i )
			begin
				red_timeout_value    <= RED_TIME_DEFAULT;
				yellow_timeout_value <= YELLOW_TIME_DEFAULT;
				green_timeout_value  <= GREEN_TIME_DEFAULT;
			end
		else
			if ( cmd_valid_i )
				case ( cmd_type_i )
					CMD_SET_RED_TIME:   red_timeout_value    <= cmd_data_i;
					CMD_SET_YELOW_TIME: yellow_timeout_value <= cmd_data_i;
					CMD_SET_GREEN_TIME: green_timeout_value  <= cmd_data_i;
				endcase
	end


// Sequence for green_blink and uncontrolled state
always_ff @(posedge clk_i)
	begin : blinker_timer_control
		if( blinker_reset )
			begin
				blinker_timer  <= BLINK_HALF_PERIOD - 1'b1;
				blinker_output <= 0;
			end
		else
			if ( blinker_timer == 0 )
				begin
					blinker_timer  <= BLINK_HALF_PERIOD - 1'b1;
					blinker_output <= ~blinker_output;
				end
			else
				blinker_timer <= blinker_timer - 1'b1;
	end


always_ff @(posedge clk_i)
	begin : FSM_assign_next_state
		if( srst_i )
			begin
				state           <= RED_ON_S;
				timeout_counter <= RED_TIME_DEFAULT;
			end
		else
			begin
				state           <= state_next;
				timeout_counter <= timeout_counter_next;
			end
	end


assign cmd_force_change_state = ( ( cmd_type_i == CMD_OFF ) || ( cmd_type_i == CMD_OFF_CONTROL ) );

always_comb
	begin : FSM_next_state
		state_next = state;
		blinker_reset = 0;
		timeout_counter_next = ( timeout_counter != 0 ) ? ( timeout_counter - 1'b1 ) :
		                                                  ( 0                      );
		if( cmd_valid_i && cmd_force_change_state )
			case ( cmd_type_i )
				CMD_OFF:         state_next = OFF_S;
				CMD_OFF_CONTROL: state_next = UNCONTROLLED_S;
				default:;
			endcase
		else
			case( state )

				RED_ON_S:
					if( timeout_counter == 0 )
						begin
							state_next = RED_YELLOW_ON_S;
							timeout_counter_next = RED_YELLOW_TIME - 1'b1;
						end

				RED_YELLOW_ON_S:
					if( timeout_counter == 0 )
						begin
							state_next = GREEN_ON_S;
							timeout_counter_next = green_timeout_value - 1'b1;
						end

				GREEN_ON_S:
					if( timeout_counter == 0 )
						begin
							state_next = GREEN_BLINK_S;
							timeout_counter_next = GREEN_BLINK_TIME - 1'b1;
							blinker_reset = 1'b1;
					end

				GREEN_BLINK_S:
					if( timeout_counter == 0 )
						begin
							state_next = YELLOW_ON_S;
							timeout_counter_next = yellow_timeout_value - 1'b1;
						end

				YELLOW_ON_S:
					if( timeout_counter == 0 )
						begin
							state_next = RED_ON_S;
							timeout_counter_next = red_timeout_value - 1'b1;
						end

				OFF_S, UNCONTROLLED_S:
					if( cmd_valid_i && ( cmd_type_i == CMD_ON ) )
						begin
							state_next = RED_ON_S;
							timeout_counter_next = red_timeout_value - 1'b1;
						end

			endcase

	end


always_ff @(posedge clk_i)
	begin : FSM_output_generate
		red_o    <= 0;
		yellow_o <= 0;
		green_o  <= 0;

		case ( state )
			RED_ON_S:        red_o    <= 1'b1;
			YELLOW_ON_S:     yellow_o <= 1'b1;
			GREEN_ON_S:      green_o  <= 1'b1;
			RED_YELLOW_ON_S:
				begin
					red_o    <= 1'b1;
					yellow_o <= 1'b1;
				end
			GREEN_BLINK_S:   green_o  <= blinker_output;
			UNCONTROLLED_S:  yellow_o <= blinker_output;
			OFF_S:;
			default:; // no action - output default zeros
		endcase
	end


endmodule
