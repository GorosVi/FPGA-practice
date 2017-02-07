module bit_population_counter #(
	parameter WIDTH = 128
)(
	input  wire                        clk_i,
	input  wire                        srst_i,

	input  wire  [ WIDTH - 1 : 0]      data_i,
	input  wire                        data_val_i,

	output logic [ $clog2(WIDTH) : 0 ] data_o,
	output logic                       data_val_o
);

logic [WIDTH - 1 : 0] [ $clog2(WIDTH) : 0] interm_result_new;
logic [WIDTH - 1 : 0] [ WIDTH - 1 : 0] interm_data_new;

always_ff @(posedge clk_i)
	for ( int i = 0; i < WIDTH; i++ )
		begin
			if( i == 0 )
				begin
					interm_data_new[i] = data_i;
					interm_result_new[i] = interm_data_new[i][i];
				end
			else
				// This magic number sets length of pipeline. Will be a number of bits in each stage
				//  (e.g. if input width is 128 and 2-stage pipeline this value is 64)
				if( ( i + 1 ) % 64 == 0 )
					begin
						interm_data_new[i]      <= interm_data_new[i-1];
						interm_result_new[i]    <= interm_result_new[i-1]     + interm_data_new[i-1][i];
					end
				else
					begin
						interm_data_new[i]      =  interm_data_new[i-1];
						interm_result_new[i]    =  interm_result_new[i-1]     + interm_data_new[i][i];
					end
		end

always_ff @(posedge clk_i)
	begin : data_pipeline_output
		data_o     <= interm_result_new[ WIDTH - 1 ];
		data_val_o <= data_val_i;
	end


endmodule
