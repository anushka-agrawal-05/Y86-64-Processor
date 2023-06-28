module xor_ (in1, in2, out);

	input  [63:0] in1, in2;
	output [63:0] out;

	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin
			xor(out[i], in1[i], in2[i]);
		end
	endgenerate

endmodule