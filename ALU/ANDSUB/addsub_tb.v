// Test bench to test the functionality of a 64 bit adder

`timescale 1ns/10ps

module addsub_tb();

reg [63:0]A;
reg [63:0]B;
reg M;

wire [63:0]SUM;
wire overflow;

addsub_ a_s (.A(A), .B(B), .M(M), .SUM(SUM), .overflow(overflow));

initial
    begin

        $dumpfile("addsub_tb.vcd");
        $dumpvars(0, addsub_tb);

        A=64'd0;
        B=64'd0;
        M=0;

    end

initial 
begin

    #10 A= 64'd5; B= 64'd105; M=0;
    #10 A=-64'd3; B=-64'd307; M=1;
    #10 A= 64'd3; B=-64'd518; M=1;
    #10 A= 64'd5; B= 64'd716; M=0;

end
endmodule