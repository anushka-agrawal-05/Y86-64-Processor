// Implementation of a 64 bit Adder and Subtractor using 64 1-bit Adders

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

input [63:0]in1;
input [63:0]in2;
input M;

output [63:0]sum;
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

