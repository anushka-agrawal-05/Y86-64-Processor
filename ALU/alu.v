`include "ADDSUB/addsub.v"
`include "AND/and.v"
`include "XOR/xor.v"

module alu_(inp1, inp2, op, out, CC);
	input signed [63:0] inp1, inp2;
	input  [1:0] op;
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