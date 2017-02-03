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

logic [WIDTH-1:0]       data_reg,
                        data_reg_new;

// Counting number of bits to transmit
logic [$clog2(WIDTH):0] rem_tx_counter,
                        rem_tx_counter_new;


always_ff @(posedge clk_i)
	begin : serial_transmitter_control
		if( srst_i )
			begin
				data_reg       <= '0;
				rem_tx_counter <= '0;
			end
		else
			begin
				data_reg       <= data_reg_new;
				rem_tx_counter <= rem_tx_counter_new;
			end
	end


always_comb
	begin : serial_transmitter_state_new
		data_reg_new       = { data_reg[WIDTH-2:0], 1'b0 };
		rem_tx_counter_new = ( rem_tx_counter != 0 ) ? ( rem_tx_counter - 1'b1 ) :
		                                               ( 1'b0 );
		if( data_val_i && ( data_mod_i > 3 )  )
			begin
				data_reg_new       = data_i;
				rem_tx_counter_new = data_mod_i;
			end
	end


always_comb
	begin : serial_transmitter_output
		ser_data_o     = data_reg[WIDTH-1];
		ser_data_val_o = ( rem_tx_counter != 0 );
		busy_o         = ( rem_tx_counter != 0 );
	end


endmodule
