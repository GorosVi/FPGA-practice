
module delay_line #(
  parameter                     DELAY = 10
)(
  input                         clk_i,
  input                         data_i,
  output logic                  data_o
);

logic [DELAY-1:0] data_d;

always_ff @( posedge clk_i )
  data_d <= {data_d[DELAY-2:0], data_i};

/* Still ok, but weird:

integer i;
always_ff @( posedge clk_i )
  begin
    data_d[0]         <= data_i;
    for( i = 1; i <= DELAY-1; i++ )
      data_d[i] <= data_d[i-1];
  end
*/

assign data_o = data_d[DELAY-1];

endmodule
