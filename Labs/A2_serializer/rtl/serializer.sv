module serializer #(
	parameter WIDTH = 16
)(
	input  wire             clk_i,
	input  wire             srst_i,

	input  wire [WIDTH-1:0] data_i,
	input  wire             data_mod_i,
	input  wire             data_val_i,

	output logic            busy_o,
	output logic            ser_data_o,
	output logic            ser_data_val_o
);


endmodule
