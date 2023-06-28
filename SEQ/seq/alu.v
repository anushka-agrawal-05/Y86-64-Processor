// `include "addsub.v"
// `include "and.v"
// `include "xor.v"

module and_ (in1, in2, out);

	input signed [63:0] in1, in2;
	output signed [63:0] out;

	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin
			and(out[i], in1[i], in2[i]);
		end
	endgenerate

endmodule

module xor_ (in1, in2, out);

	input signed [63:0] in1, in2;
	output signed [63:0] out;

	genvar i;
	generate
		for (i = 0; i < 64; i = i + 1) begin
			xor(out[i], in1[i], in2[i]);
		end
	endgenerate

endmodule

module FA(a, b, c, M, sum, carry);

input a, b, c;
input M;
output sum, carry;
wire B, x, y, z;

xor x1(B, b, M);

xor x2(x, a, B);
xor x3(sum, x, c);
and a1(y, a, B);
and a2(z, x, c);
or o1(carry, y, z);

endmodule


module addsub_(in1, in2, M, sum, overflow);

input signed [63:0]in1;
input signed[63:0]in2;
input M;

output signed [63:0]sum;
output overflow;

wire [64:0]C;

assign C[0] = M;

genvar i;

generate
    for(i = 0; i < 64; i=i+1)
    begin
        FA full_adder(in1[i], in2[i], C[i], M, sum[i], C[i+1]);
    end
endgenerate


xor x1(overflow, C[64], C[63]);

endmodule

module alu_(inp1, inp2, op, out, CC);
	input signed [63:0] inp1, inp2;
	input [1:0] op;
	output signed [63:0] out;
	output [2:0] CC;

	wire signed [63:0] out_add, out_sub, out_and, out_xor;
    reg signed [63:0] ans;
	reg overflow_;

	addsub_ add (inp1, inp2, 1'b0, out_add, overflow1);
	addsub_ sub (inp1, inp2, 1'b1, out_sub, overflow2);
	and_ a1 (inp1, inp2, out_and);
	xor_ x1 (inp1, inp2, out_xor);

    always@(*)
    begin
		if(op==2'b00) 
		begin
			ans = out_add;
			overflow_ = overflow1;
		end
		else if(op == 2'b01) 
		begin
			ans = out_sub;
			overflow_ = overflow2;
		end
        else if(op == 2'b10) 
		begin
            ans = out_and;
			overflow_ = 1'b0;
		end
        else if(op == 2'b11)
		begin
            ans = out_xor;
			overflow_ = 1'b0;
		end
    end
	
    assign out = ans;
	// Zero Flag
	assign CC[2] = (ans==64'b0);
	// Sign Flag
	assign CC[1] = (ans[63]==1);
	// Overflow Flag
	assign CC[0] = overflow_;

endmodule