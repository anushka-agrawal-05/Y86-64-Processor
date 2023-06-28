`timescale 1ns / 10ps

module execute_tb;
  reg clk;

  reg [3:0] icode;
  reg [3:0] ifun;
  reg [63:0] valC;
  reg [63:0] valA;
  reg [63:0] valB;
  output signed [63:0] valE;
  output cnd;

  execute execute(
    .clk(clk),
    .icode(icode),
    .ifun(ifun),
    .valA(valA),
    .valB(valB),
    .valC(valC),
    .valE(valE),
    .cnd(cnd)
  );

  initial
  begin

    $dumpfile("execute_tb.vcd");
    $dumpvars(0, execute_tb);

    clk=0;
    icode=4'd0;
    ifun=4'd0;
    valC=64'd0;
    valA=64'd0;
    valB=64'd0;    

  end

  initial begin
    clk=0;

    #10 clk=~clk;
    icode=4'b0110;
    ifun=4'b0001;
    valA=64'd10;
    valB=64'd50;
    valC=64'd20;
    #10 clk=~clk;
    #10 clk=~clk;
    icode=4'b0111;
    ifun=4'b0100;
    valA=64'd10;
    valB=64'd50;
    valC=64'd20;
    #10 clk=~clk;
    #10 clk=~clk;
    icode=4'b1000;
    ifun=4'b0000; 
    valA=64'd10;
    valB=64'd50;
    valC=64'd20;
    #10 clk=~clk;
    
  end 
  
  initial 
		$monitor("clk=%d icode=%b ifun=%b valA=%d valB=%d valC=%d valE=%d cnd=%d\n",clk,icode,ifun,valA,valB,valC,valE, cnd);
endmodule