module debouncer #(
	parameter CLK_FREQ_MHZ   = 20,
	parameter GLITCH_TIME_NS = 1600
)(
	input  wire  clk_i,
	input  wire  srst_i,
	input  wire  key_i,
	output logic key_pressed_stb_o
);


localparam GLITCH_TIME_CLK = GLITCH_TIME_NS * CLK_FREQ_MHZ / ( 10 ** 3 );
localparam TIMEOUT_COUNTER_WIDTH = $clog2(GLITCH_TIME_CLK);
logic key_edge, key_i_delayed;
logic [TIMEOUT_COUNTER_WIDTH-1:0] timeout_counter;


always_ff @( posedge clk_i )
	if(srst_i)
		timeout_counter <= 0;
	else
		begin
			key_i_delayed <= key_i;
			key_edge <= ( ~key_i & key_i_delayed ) && ( timeout_counter == 0 );
			if( key_edge )
				timeout_counter <= GLITCH_TIME_CLK - 1;
			if( timeout_counter != 0 )
				timeout_counter <= timeout_counter - 1;
		end


assign key_pressed_stb_o = key_edge;


endmodule
