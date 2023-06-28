//PC UPDATE BLOCK

module pc_update (clk, cnd, icode, valC, valM, valP, updated_pc);

    input clk;
    input cnd;
    input [3:0] icode;
    input [63:0] valC;
    input [63:0] valM;
    input [63:0] valP;
    input [63:0] PC;
    output reg [63:0] updated_pc;

    // instruction codes
    parameter IHALT   = 4'd0;
    parameter INOP    = 4'd1;
    parameter IRRMOVQ = 4'd2; //rrmovq and  cmovXX
    parameter IIRMOVQ = 4'd3;
    parameter IRMMOVQ = 4'd4;
    parameter IMRMOVQ = 4'd5;
    parameter IOPQ    = 4'd6;
    parameter IJXX    = 4'd7;
    parameter ICALL   = 4'd8;
    parameter IRET    = 4'd9;
    parameter IPUSHQ  = 4'd10;
    parameter IPOPQ   = 4'd11;

    always@(*)
    begin
        if(icode == IJXX)
        begin
            if(cnd == 1'b1)
                updated_pc = valC;
            else
                updated_pc = valP;
        end
        else if(icode == ICALL)
        begin
            updated_pc = valC;
        end
        else if(icode == IRET)
        begin
            updated_pc = valM;
        end
        else
        begin
            updated_pc  = valP;
        end      
    end

endmodule