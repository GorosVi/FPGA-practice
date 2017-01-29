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
	.clk_i             ( clk               ),
	.srst_i            ( srst              ),

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


logic [WIDTH-1:0] data_temp_storg;

initial
	begin : test_sequence_generator
		data_i     = 1'b0;
		data_val_i = 1'b0;
		repeat (3) @( posedge clk );

		// TEST 1: run WIDTH clock cycles with data_val_i active. Module should give result to output
		data_val_i = 1'b1;
		data_i     = 1'b1;
		repeat (WIDTH)
			begin
				@( posedge clk );
				data_i     = ~data_i;
				assert ( deser_data_val_o == 0 ) else $error ("Error: deser_data_o is ready too fast (test 1_1)");
			end
		data_val_i = 1'b0;
		data_i     = 1'b0;
		@( posedge clk );
		@( posedge clk );
		assert ( deser_data_val_o == 1 ) else $error ("Error: deser_data_o not ready (test 1_2)");

		// TEST 2: run WIDTH*2 clock cycles with data_val_i active in half of this. Module should give result to output.
		repeat (WIDTH)
			begin
				data_i     = 1'b1;
				data_val_i = 1'b1;
				@( posedge clk );
				assert ( deser_data_val_o == 0 ) else $error ("Error: deser_data_o is ready too fast (test 2_1)");
				data_i     = 1'b0;
				data_val_i = 1'b0;
				@( posedge clk );
				assert ( deser_data_val_o == 0 ) else $error ("Error: deser_data_o is ready too fast (test 2_2)");
			end
		@( posedge clk );
		assert ( deser_data_val_o == 1 ) else $error("Error: deser_data_o not ready (test 2_3)");

		// TEST 3 : correctly continuous run. Comparing results from two sequential (non-stop)
		//  runs with identical data pattern.
		data_val_i = 1'b1;
		data_i     = 1'b1;
		repeat (WIDTH)
			begin
				@( posedge clk );
				data_i = ~data_i;
			end
		// Invert data for odd deserializer widths, otherwise results of two sequential runs will be not same
		if( ( WIDTH % 2 ) > 0 )
			data_i = ~data_i;

		@( posedge clk );
		data_i = ~data_i;
		@( posedge clk );
		data_i = ~data_i;

		assert ( deser_data_val_o == 1 ) else $error("Error: deser_data_o not ready (test 3_1)");
		data_temp_storg = deser_data_o;

		repeat (WIDTH - 2)
			begin
				@( posedge clk );
				data_i = ~data_i;
			end

		data_val_i = 1'b0;
		data_i     = 1'b0;
		@( posedge clk );
		@( posedge clk );
		assert ( deser_data_val_o == 1 ) else $error ("Error: deser_data_o not ready (test 3_2)");
		assert ( data_temp_storg == deser_data_o ) else $error ("Error: deser_data_o not matched with previous result (test 3_3)");

		data_val_i = 1'b0;
		repeat (5) @( posedge clk );
		$stop;
	end


endmodule
