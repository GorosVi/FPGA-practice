module serializer #(
	parameter WIDTH = 16
)(
	input  wire                   clk_i,
	input  wire                   srst_i,

	input  wire [WIDTH-1:0]       data_i,
	input  wire [$clog2(WIDTH):0] data_mod_i,
	input  wire                   data_val_i,

	output logic                  busy_o,
	output logic                  ser_data_o,
	output logic                  ser_data_val_o
);

logic input_valid;

assign input_valid = ( data_val_i && ( data_mod_i > 3 ) );


logic [WIDTH-1:0]       data_reg;
logic [WIDTH-1:0]       data_reg_next;

// Remaining bits to transmit
logic [$clog2(WIDTH):0] rem_tx_counter;
logic [$clog2(WIDTH):0] rem_tx_counter_next;

enum logic { READY_S,
             TRANSMIT_S } state, state_next;


always_ff @(posedge clk_i)
	begin : FSMD_state_control
		if( srst_i )
			begin
				state          <= READY_S;
				data_reg       <= '0;
				rem_tx_counter <= '0;
			end
		else
			begin
				state          <= state_next;
				data_reg       <= data_reg_next;
				rem_tx_counter <= rem_tx_counter_next;
			end
	end


always_comb
	begin : FSMD_state_next
		data_reg_next       = data_reg;
		rem_tx_counter_next = rem_tx_counter;
		case( state )
			READY_S:
				begin
					if( input_valid )
						begin
							state_next          = TRANSMIT_S;
							data_reg_next       = data_i;
							rem_tx_counter_next = data_mod_i - 1;
						end
					else
						state_next = READY_S;
				end

			TRANSMIT_S:
				begin
					if( rem_tx_counter == 0 )
						state_next = READY_S;
					else
						begin
							state_next          = TRANSMIT_S;
							data_reg_next       = data_reg << 1'b1;
							rem_tx_counter_next = rem_tx_counter - 1'b1;
						end
				end
			default:
				begin
					state_next = READY_S;
				end
		endcase
	end

always_comb
	begin : FSMD_output
		busy_o         = (state == TRANSMIT_S);
		ser_data_o     = data_reg[WIDTH-1];
		ser_data_val_o = (state == TRANSMIT_S);
	end

endmodule
