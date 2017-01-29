`timescale 10 ps / 10 ps

module tb;

localparam CLK_HALF_PERIOD = 5;
localparam WIDTH           = 16;

logic             clk;
logic             srst;

logic [WIDTH-1:0] data_i;
logic             data_mod_i;
logic             data_val_i;

logic             busy_o;
logic             ser_data_o;
logic             ser_data_val_o;


serializer #(
	.WIDTH             ( WIDTH             )
) i_serializer (
	.clk_i             ( clk               ),
	.srst_i            ( srst              ),

	.data_i            ( data_i            ),
	.data_mod_i        ( data_mod_i        ),
	.data_val_i        ( data_val_i        ),

	.busy_o            ( busy_o            ),
	.ser_data_o        ( ser_data_o        ),
	.ser_data_val_o    ( ser_data_val_o    )
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