module packet_classer (
	input  wire         clk_i,
	input  wire         srst_i,

	avalon_st_if.snk      snk_if,
	avalon_st_if.src      src_if,

	input [11:0][7:0]   key
);



logic [7:0][7:0] data_d1, data_d2;

logic [18:0][7:0] window;

logic [7:0] pattern;

assign window = {snk_if.data[2:0], data_d1, data_d2};

logic match;
logic [11:0][7:0] key_reordered; // we need to change data order due to data mapping

genvar j;
generate
for( j = 0; j < 8; j++ )
		begin : byte_reorder
			assign key_reordered[j] = key_i[11-j];
		end
endgenerate

// search logic

genvar i;
generate
	for( i = 0; i < 8; i++ )
		begin : gen_comparators
			// assign pattern[0] = ( window[11:0] == key_reordered );
			// assign pattern[1] = ( window[12:1] == key_reordered );
			assign pattern[i] = ( window[11+i:0+i] == key_reordered );
		end
endgenerate



// pipeline
logic data_d1_ena, data_d2_ena;

assign src_if.valid = ( val_d2 && val_d1 && snk_if.valid ) ||
                      ( val_d2 && val_d1 && eop_d1 ) ||
                      ( val_d2 && eop_d2);

assign data_d2_ena = ( src_if.valid && src_if.ready ) || !val_d2;
assign data_d1_ena =  data_d2_ena || !val_d1;

always_ff @(posedge clk_i)
begin
	if( data_d1_ena )
		begin
			data_d1  <= snk_if.data;
			val_d1   <= snk_if.valid;
			sop_d1   <= snk_if.startofpacket;
			eop_d1   <= snk_if.endofpacket
			empty_d1 <= snk_if.empty;
		end
end

always_ff @(posedge clk_i)
begin
	if( data_d1_ena )
		begin
			data_d2  <= data_d1;
			val_d2   <= val_d1;
			sop_d2   <= sop_d1;
			eop_d2   <= eop_d1;
			empty_d2 <= empty_d1;
		end
end

assign snk_if.ready = data_d1_ena;

// pipeline signals
logic [7:0][7:0] data_d1, data_d2
logic val_d1, val_d2;
logic sop_d1, sop_d2;
logic eop_d1, eop_d1;
logic [2:0] empty_d1, empty_d2;


always_ff @(posedge clk_i )
begin : proc_
	if( srst_i )
		match <= '0;
	else
		if( src_if.ready && src_if.valid && src_if.endofpacket )
			match <= '0;
		else
			if( |pattern )
				match <= 1'b1;
	end
end

// assign output
assign snk_if.data = data_d2;
assign snk_if.startofpacket = sop_d2;
assign snk_if.endofpacket = eop_d2;
assign snk_if.empty = empty_d2;

endmodule
