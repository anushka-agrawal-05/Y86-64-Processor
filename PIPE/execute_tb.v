`timescale 1ns/10ps

`include "fetch.v"
`include "decode.v"
`include "execute.v"

module execute_tb();

    reg clk;
    reg [63:0] F_predPC;

    reg F_stall, D_stall, D_bubble, E_bubble;
    reg set_cc;

    wire [3:0] M_icode;
    wire M_cnd;
    wire [63:0] M_valA;


    wire [3:0] W_icode;

    wire [3:0] e_dstE, M_dstM, M_dstE;
    wire [3:0] W_dstM, W_dstE;
    wire [63:0] e_valE, m_valM, M_valE, W_valM, W_valE;

    wire [63:0] f_predPC;

    wire [3:0] D_icode;
    wire [3:0] D_ifun;

    wire [3:0] D_rA;
    wire [3:0] D_rB;

    wire [63:0] D_valC;
    wire [63:0] D_valP;

    wire [1:0] D_stat;  //AOK|HLT|ADR|INS

    wire [63:0] d_valA, d_valB;
    wire [3:0] d_srcA, d_srcB;

    wire [3:0] E_icode;
    wire [3:0] E_ifun;

    wire [63:0] E_valA;
    wire [63:0] E_valB;
    wire [63:0] E_valC;

    wire [3:0] E_dstE;
    wire [3:0] E_dstM;
    wire [3:0] E_srcA;
    wire [3:0] E_srcB;

    wire [1:0] E_stat;  //AOK|HLT|ADR|INS

    
    wire[1:0] M_stat;
    wire e_cnd;

    fetch fetch_(clk, F_predPC, M_icode, M_cnd, M_valA, W_icode, W_valM, F_stall, D_stall, D_bubble, f_predPC, D_icode, D_ifun, D_rA, D_rB, D_valC, D_valP, D_stat);
    decode decode_(clk, D_icode, D_ifun, D_rA, D_rB, D_valC, D_valP, D_stat, e_dstE, M_dstM, M_dstE, W_dstM, W_dstE, e_valE, m_valM, M_valE, W_valM, W_valE, E_bubble, E_icode, E_ifun, E_valA, E_valB, E_valC, E_dstE, E_dstM, E_srcA, E_srcB, E_stat, d_srcA, d_srcB, d_valA, d_valB);
    execute execute_(clk, E_stat, E_icode, E_ifun, E_valC, E_valA, E_valB, E_dstE, E_dstM, set_cc, M_stat, M_icode, M_cnd, M_valE, M_valA, M_dstE, M_dstM, e_valE, e_dstE, e_cnd);

    always @(M_icode) 
    begin
        if(M_icode==0) 
        $finish;
    end

  always @(posedge clk) F_predPC <= f_predPC;

  always #10 clk = ~clk;

  initial
  begin

    $dumpfile("execute_tb.vcd");
    $dumpvars(0, execute_tb);

    F_predPC = 64'd32;
    clk = 0;
    F_stall = 0;
    D_stall = 0;
    D_bubble = 0;
    E_bubble = 0;

  end

  initial 
  begin
    $monitor($time, "\tclk=%d\n\t\t\tF Reg:\t\tF_predPC = %g\n\t\t\tfetch:\t\tf_predPC = %g\n\t\t\tD Reg:\t\tD_icode = %b D_ifun = %b D_rA = %b D_rB = %b D_valC = %g D_valP = %g D_stat = %g\n\t\t\tdecode:\t\td_valA = %g d_valB = %g\n\t\t\tE Reg:\t\tE_icode = %b E_ifun = %b E_valA = %g E_valB = %g E_valC = %g E_dstE = %b E_dstM = %b E_srcA = %g E_srcB = %g E_stat = %g\n\t\t\texecute:\te_cnd = %b e_valE = %g\n\t\t\tM Reg:\t\tM_icode = %b M_cnd = %b M_valA = %g M_valE = %g M_dstE = %b, M_dstM = %b M_stat = %g\n",clk,F_predPC,f_predPC,D_icode,D_ifun,D_rA,D_rB,D_valC,D_valP,D_stat,d_valA,d_valB,E_icode,E_ifun,E_valA,E_valB,E_valC,E_dstE,E_dstM,E_srcA,E_srcB,E_stat,e_cnd,e_valE,M_icode,M_cnd,M_valA,M_valE,M_dstE,M_dstM,M_stat);
  end


endmodule
