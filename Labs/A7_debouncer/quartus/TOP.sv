module TOP (
input  wire clk_i,
input  wire srst_i,
input  wire key_i,

output wire key_pressed_stb_o
);


debouncer i_debouncer (
	.clk_i             ( clk_i ),
	.srst_i            ( srst_i ),
	.key_i             ( key_i ),
	.key_pressed_stb_o ( key_pressed_stb_o )
);


endmodule
