`timescale 1ns/10ps

`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
`include "write_back.v"
`include "pc_update.v"

module seq();
    reg clk;
    reg [63:0] PC;

    reg stat_AOK;
    reg stat_INS;
    reg stat_HLT;
    reg stat_ADR;

    wire [3:0] icode;
    wire [3:0] ifun;
    wire [3:0] rA;
    wire [3:0] rB; 
    wire [63:0] valC;
    wire [63:0] valP;
    wire instr_valid;
    wire imem_error;
    wire dmem_error;
    wire [63:0] valA;
    wire [63:0] valB;
    wire signed [63:0] valE;
    wire [63:0] valM;
    wire [63:0] datamem;
    wire cnd;
    output hlt;
    wire [63:0] updated_pc;
    wire [63:0] memory_address;

    fetch fetch_(clk, PC, icode, ifun, rA, rB, valC, valP, imem_error, instr_valid, hlt);
    decode decode_(clk, icode, rA, rB, valA, valB);
    execute execute_(clk, icode, ifun, valA, valB, valC, valE, cnd);
    memory memory_(clk, icode, valA, valE, valP, valM, dmem_error, datamem, memory_address);
    write_back write_back_(clk, icode, rA, rB, cnd, valE, valM);
    pc_update pc_update_(clk, cnd, icode, valC, valM, valP, updated_pc);

    initial 
    begin
        $dumpfile("seq.vcd");
        $dumpvars(0, seq);
        clk = 1;
        PC = 64'd0;
        stat_AOK = 1;
        stat_INS = 0;
        stat_HLT = 0;
	stat_ADR = 0;
    end

    always #5 clk =~ clk;

    always@(*)
    begin
        if(hlt)
        begin
        stat_AOK=1'b0;
        stat_INS=1'b0;
        stat_HLT=1'b1;
        stat_ADR=1'b0;
        end
        else if(instr_valid)
        begin
        stat_AOK=1'b0;
        stat_INS=1'b1;
        stat_HLT=1'b0;
        stat_ADR=1'b0;
        end
        else if(imem_error == 1 || dmem_error == 1)
        begin
        stat_AOK=1'b0;
        stat_INS=1'b0;
        stat_HLT=1'b0;
        stat_ADR=1'b1;
        end
        else
        begin
        stat_AOK=1'b1;
        stat_INS=1'b0;
        stat_HLT=1'b0;
        stat_ADR=1'b0;
        end
    end

    always@(*)
    begin
        PC = updated_pc;
    end

    always@(*)
    begin
        if(stat_ADR == 1)
        begin
            $finish;
        end
        else if (stat_HLT == 1)
        begin
            $finish;
        end
    end

 initial
	$monitor($time, "    clk = %d icode = %b ifun = %b rA = %b rB = %b\n\t\t\tvalA = %g valB = %g valC = %g valE = %g valM = %g updated_pc = %g\n\t\t\tdatamem = %g memory_address = %g dmem_error = %d instr_invalid = %d memory_error = %d cnd = %d HLT = %d AOK = %d INS = %d ADR = %d\n",clk,icode,ifun,rA,rB,valA,valB,valC,valE,valM,updated_pc,datamem,memory_address,dmem_error,instr_valid,imem_error,cnd,stat_HLT,stat_AOK,stat_INS,stat_ADR);

endmodule


