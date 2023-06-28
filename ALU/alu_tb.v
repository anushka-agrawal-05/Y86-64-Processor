`timescale 1ns / 1ps

module alu_tb;
	reg signed [63:0] inp1, inp2;
	reg [ 1:0] op;
	output signed [63:0] out;
	output wire [2:0] CC;

	alu_ opera_n(inp1, inp2, op, out, CC);

	initial begin
		$dumpfile("alu_tb.vcd");
		$dumpvars(0, alu_tb);

		$monitor($time, " Operation = %b\n\t\t     inp1 = %b = %d\n\t\t     inp2 = %b = %d\n\t\t     out  = %b = %d\n\t\t     ZF = %d\n\t\t     SF = %d\n\t\t     OF = %d\n", op, inp1, inp1, inp2, inp2, out, out, CC[2], CC[1], CC[0]);

		op = 2'b00; inp1 = 64'b0; inp2 = 64'b0;
		#20 op = 2'b00; inp1 =  64'b110101; inp2 =  64'b010110;
		#20 op = 2'b01; inp1 =  64'b110101; inp2 =  64'b010110;
		#20 op = 2'b10; inp1 =  64'b110101; inp2 =  64'b010110;
		#20 op = 2'b11; inp1 =  64'b110101; inp2 =  64'b010110;
		#20 op = 2'b00; inp1 = -64'b110101; inp2 =  64'b010110;
		#20 op = 2'b01; inp1 = -64'b110101; inp2 =  64'b010110;
		#20 op = 2'b10; inp1 = -64'b110101; inp2 =  64'b010110;
		#20 op = 2'b11; inp1 = -64'b110101; inp2 =  64'b010110;
		#20 op = 2'b00; inp1 =  64'b110101; inp2 = -64'b010110;
		#20 op = 2'b01; inp1 =  64'b110101; inp2 = -64'b010110;
		#20 op = 2'b10; inp1 =  64'b110101; inp2 = -64'b010110;
		#20 op = 2'b11; inp1 =  64'b110101; inp2 = -64'b010110;
		#20 op = 2'b00; inp1 = -64'b110101; inp2 = -64'b010110;
		#20 op = 2'b01; inp1 = -64'b110101; inp2 = -64'b010110;
		#20 op = 2'b10; inp1 = -64'b110101; inp2 = -64'b010110;
		#20 op = 2'b11; inp1 = -64'b110101; inp2 = -64'b010110;
		#20 op = 2'b00; inp1 =  64'd9223372036854775807; inp2 =  64'd1;
		#20 op = 2'b01; inp1 =  64'd9223372036854775807; inp2 = -64'd1;

		$finish;
	end
endmodule