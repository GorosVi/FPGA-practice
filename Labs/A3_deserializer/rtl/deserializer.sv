module deserializer #(
	parameter WIDTH = 16
)(
	input  wire              clk_i,
	input  wire              srst_i,

	input  wire              data_i,
	input  wire              data_val_i,

	output logic [WIDTH-1:0] deser_data_o,
	output logic             deser_data_val_o
);

// Bits are counted in range [1..2**WIDTH], and standard
//  width [$clog2(WIDTH):0] causes overflow situation
logic [$clog2(WIDTH)+1:0] rx_bit_count;
logic [WIDTH-1:0]         rx_data;


always_ff @(posedge clk_i)
	begin : receiving_data
		if( srst_i )
			begin
				// rx_data      <= 0;
				rx_bit_count <= 0;
			end
		else
			begin
				if( data_val_i == 1'b1 )
					rx_data <= {rx_data, data_i};

				// Receiving complete
				if( rx_bit_count < WIDTH )
					rx_bit_count <= ( data_val_i == 1'b1 ) ? ( rx_bit_count + 1'b1 ) :
					                                         ( rx_bit_count        );
				else // When receiving is active - write value considering received bit at this clock cycle
					rx_bit_count <= ( data_val_i == 1'b1 ) ? ( 1'b1                ) :
					                                         ( 1'b0                );
			end
	end


always_ff @(posedge clk_i)
	begin : output_data_when_receiving_completed
		if( rx_bit_count == WIDTH )
			begin
				deser_data_o     <= rx_data;
				deser_data_val_o <= 1'b1;
			end
		else
			begin
				// deser_data_o     <= 0;
				deser_data_val_o <= 0;
			end
	end

endmodule
