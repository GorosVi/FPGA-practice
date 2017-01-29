module TOP #(
	parameter WIDTH = 16
)(
	input  wire              clk_i,
	input  wire              srst_i,

	input  wire              data_i,
	input  wire              data_val_i,

	output logic [WIDTH-1:0] deser_data_o,
	output logic             deser_data_val_o
);


deserializer #(
	.WIDTH             ( WIDTH             )
) i_deserializer (
	.clk_i             ( clk_i             ),
	.srst_i            ( srst_i            ),

	.data_i            ( data_i            ),
	.data_val_i        ( data_val_i        ),

	.deser_data_o      ( deser_data_o      ),
	.deser_data_val_o  ( deser_data_val_o  )
);


endmodule
