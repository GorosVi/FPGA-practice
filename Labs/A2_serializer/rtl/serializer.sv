module serializer #(
	parameter WIDTH = 16,
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

logic [WIDTH-1:0]       data;
logic                   data_out;
logic                   data_valid;
logic [$clog2(WIDTH):0] remaining_tx_bits_count;

logic                   input_valid

assign input_valid = ( data_val_i && ( data_mod_i > 3 ) )

always_ff @( posedge clk_i )
	begin : transmit_counter_control
		if( srst_i )
			remaining_tx_bits_count <= 0;
		else
			if( remaining_tx_bits_count > 0 )
				// Transmit MSB to data output
				remaining_tx_bits_count <= remaining_tx_bits_count - 1'b1;
			else
				if( input_valid )
					// Read data and start transaction
					remaining_tx_bits_count <= data_mod_i;
				else
					remaining_tx_bits_count <= 0;
	end


always_ff @(posedge clk_i)
	begin : transmit_data
		if( srst_i )
			begin
				data <= 0;
				data_valid <= 0;
			end
		else
			if( remaining_tx_bits_count > 0 )
				// Transmit MSB to data output
				remaining_tx_bits_count <= remaining_tx_bits_count - 1'b1;
			else
				if( input_valid )
					// Read data and start transaction
					remaining_tx_bits_count <= data_mod_i;
				else
					remaining_tx_bits_count <= 0;


		if (srst_i)
			begin
				data <= 0;
				data_valid <= 0;
			end
		else
			// Transmit MSB to data output
			if( remaining_tx_bits_count > 0 )
				begin
					data_out   <= data[WIDTH-1];
					data_valid <= 1'b1;

					data       <= {data[WIDTH-2:0],1'b0} // check << operator!
				end
			// Read data and start transaction
			else
				if( data_val_i  )
					begin
						data <=
					end
	end


endmodule
