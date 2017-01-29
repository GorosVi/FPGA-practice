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


endmodule
