module debouncer
#( parameter CLK_FREQ_MHZ = 20, GLITCH_TIME_NS = 200)
 ( input  wire  clk_i, key_i,
   output logic key_pressed_stb_o );
localparam GLITCH_TIME_CLK = GLITCH_TIME_NS * CLK_FREQ_MHZ / ( 10 ** 3 );
logic [GLITCH_TIME_CLK:0] buffer;
always_ff @(posedge clk_i)
	buffer <= { buffer[GLITCH_TIME_CLK-1:0], ~key_i };
assign key_pressed_stb_o = ( &buffer[GLITCH_TIME_CLK-1:0] ) && ( ~buffer[GLITCH_TIME_CLK] );
endmodule