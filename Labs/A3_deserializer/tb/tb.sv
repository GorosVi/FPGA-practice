`timescale 10 ps / 10 ps

module tb;

localparam CLK_HALF_PERIOD = 5;
localparam WIDTH           = 16;

logic             clk;
logic             srst;

logic             data_i;
logic             data_val_i;

logic [WIDTH-1:0] deser_data_o;
logic             deser_data_val_o;


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


initial
	begin : clk_generator
		clk = 1'b0;
		forever #CLK_HALF_PERIOD clk = ~clk;
	end


initial
	begin : sync_reset_generator
		srst = 1'b1;
		#( CLK_HALF_PERIOD + 1 ) srst = 1'b0;
	end


initial
	begin : test_sequence_generator
		repeat (10) @( posedge clk );
		$stop;
	end


endmodule
