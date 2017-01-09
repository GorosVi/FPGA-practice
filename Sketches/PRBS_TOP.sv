module PRBS_TOP(
input wire clk,
input wire srst,
output wire dout
);

prbs_gen i1 (
// port map - connection between master ports and signals/registers   
        .clk(clk),
        .dout(dout),
        .srst(srst)
);

endmodule
