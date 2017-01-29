module TOP #(
	parameter WIDTH = 16
)(
	input  wire              clk_i,
	input  wire              srst_i,

	input  wire  [WIDTH-1:0] data_i,
	input  wire              data_mod_i,
	input  wire              data_val_i,

	output logic             busy_o,
	output logic             ser_data_o,
	output logic             ser_data_val_o
);


serializer #(
	.WIDTH             ( WIDTH             )
) i_serializer (
	.clk_i             ( clk_i             ),
	.srst_i            ( srst_i            ),

	.data_i            ( data_i            ),
	.data_mod_i        ( data_mod_i        ),
	.data_val_i        ( data_val_i        ),

	.busy_o            ( busy_o            ),
	.ser_data_o        ( ser_data_o        ),
	.ser_data_val_o    ( ser_data_val_o    )
);


endmodule
