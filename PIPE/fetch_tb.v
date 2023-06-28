`timescale 1ns / 10ps

`include "fetch.v"

module fetch_tb();
  
    reg clk;
    reg [63:0] F_predPC;

    reg [3:0] M_icode;
    reg M_cnd;
    reg [63:0] M_valA;

    reg [3:0] W_icode;
    reg [63:0] W_valM;

    reg F_stall, D_stall, D_bubble;

    wire [63:0] f_predPC;

    wire [3:0] D_icode;
    wire [3:0] D_ifun;

    wire [3:0] D_rA;
    wire [3:0] D_rB;

    wire [63:0] D_valC;
    wire [63:0] D_valP;

    wire [1:0] D_stat;  //AOK|HLT|ADR|INS


  fetch UUT(clk, F_predPC, M_icode, M_cnd, M_valA, W_icode, W_valM, F_stall, D_stall, D_bubble, f_predPC, D_icode, D_ifun, D_rA, D_rB, D_valC, D_valP, D_stat);


  always @(D_icode) 
  begin
    if(D_icode==0) 
      $finish;
  end

  always @(posedge clk) F_predPC <= f_predPC;

  always #10 clk = ~clk;

  initial 
  begin 

    $dumpfile("fetch_tb.vcd");
    $dumpvars(0, fetch_tb);

    F_predPC = 64'd32;
    clk = 0;
    F_stall = 0;
    D_stall = 0;
    D_bubble = 0;

  end 
  
  initial 
  begin
    $monitor($time, "\tclk=%d\n\t\t\tF Reg:\t\tF_predPC = %g\n\t\t\tfetch:\t\tf_predPC = %g\n\t\t\tD Reg:\t\tD_icode = %b D_ifun = %b D_rA = %b D_rB = %b D_valC = %g D_valP = %g D_stat = %g\n",clk,F_predPC,f_predPC,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,D_stat,);
  end

endmodule




