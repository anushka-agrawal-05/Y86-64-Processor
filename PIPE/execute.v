`include "alu.v"

module execute(clk, E_stat, E_icode, E_ifun, E_valC, E_valA, E_valB, E_dstE, E_dstM, set_cc, M_stat, M_icode, M_cnd, M_valE, M_valA, M_dstE, M_dstM, e_valE, e_dstE, e_cnd);

    input clk;
    input[1:0] E_stat;
    input [3:0] E_icode, E_ifun;
    input [63:0] E_valC, E_valA, E_valB;
    input [3:0] E_dstE, E_dstM;
    // input M_bubble;  
    input set_cc;

    output reg [1:0] M_stat;
    output reg [3:0] M_icode;
    output reg M_cnd;
    output reg [63:0] M_valE, M_valA, e_valE;
    output reg [3:0] M_dstE, M_dstM, e_dstE;
    output reg e_cnd;

    reg [3:0] icode;
    reg [3:0] ifun;
    reg [63:0] valA;
    reg [63:0] valB;
    reg [63:0] valC;
    reg signed [63:0] valE;
    reg signed cnd;

    // Condition Code [ZF, SF, OF]
    reg [2:0] CC;
    reg zf;
    reg sf;
    reg of;

    // reg [63:0] aluA, aluB;
    wire signed [63:0]ans;
    wire [2:0] conCode;
    reg signed [63:0] aluA, aluB;
    reg [1:0] op;


    // Instruction codes
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

    //Intialisation
    initial 
    begin
        valE = 64'd0;
        cnd = 1'b0;
        CC = 3'd0;
        zf = 0;
        sf = 0;
        of = 0;
    end

    always@(*) 
    begin
        e_dstE = E_dstE;
    end

    always@(*)
    begin
        valA = E_valA;
        valB = E_valB;
        valC = E_valC;
        icode = E_icode;
        ifun = E_ifun;
    end

    always@(*)
    begin
        e_valE = valE;
        e_cnd = cnd;
    end

    always@(*)
    begin
        zf = CC[2];
        sf = CC[1];
        of = CC[0];
    end

    alu_ uut(aluA, aluB, op, ans, conCode);

    always @(*)
    begin
        if(icode == IRRMOVQ)
        begin
            valE = valA;
            if(ifun == 4'd0)
            begin
                cnd = 1;
            end
            else if(ifun == 4'd1)
            begin
                cnd = ((sf^of)| zf);
            end
            else if(ifun == 4'd2)
            begin
                cnd = (sf^of);
            end
            else if(ifun == 4'd3)
            begin
                cnd = zf;
            end
            else if(ifun == 4'd4)
            begin
                cnd = ~zf;
            end
            else if(ifun == 4'd5)
            begin
                cnd = ~(sf^of);
            end
            else if(ifun == 4'd6)
            begin
                cnd = ((~(sf^of))&~zf);
            end
            e_dstE = e_cnd ? E_dstE : 4'd15;
        end
        else if(icode == IIRMOVQ)
        begin
            valE = valC;
        end
        else if(icode == IRMMOVQ)
        begin
            valE = valC+valB;
        end
        else if(icode == IMRMOVQ)
        begin
            valE = valC+valB;
        end
        else if(icode == IOPQ)
        begin
            aluA = valB;
            aluB = valA;
            if(ifun==4'b0000)
                op = 2'b00;
            else if(ifun==4'b0001)
                op = 2'b01;
            else if(ifun==4'b0010)
                op = 2'b10;
            else
                op = 2'b11;
            // assign ans_ = ans;
            valE = ans;
            // assign CC_ = conCode;
            if(set_cc==1)
                CC = conCode;
        end
        else if(icode== IJXX)
        begin
            if(ifun == 4'd0)
            begin
                cnd = 1;
            end
            else if(ifun == 4'd1)
            begin
                cnd = ((sf^of)| zf);
            end
            else if(ifun == 4'd2)
            begin
                cnd = (sf^of);
            end
            else if(ifun == 4'd3)
            begin
                cnd = zf;
            end
            else if(ifun == 4'd4)
            begin
                cnd = ~zf;
            end
            else if(ifun == 4'd5)
            begin
                cnd = ~(sf^of);
            end
            else if(ifun == 4'd6)
            begin
                cnd = ((~(sf^of))&~zf);
            end
            e_dstE = e_cnd ? E_dstE : 4'd15;
        end
        else if(icode == ICALL)
        begin
            valE = -64'd1+valB;
        end
        else if(icode == IRET)
        begin
            valE = 64'd1+valB;
        end
        else if(icode == IPUSHQ)
        begin
            valE = -64'd1+valB;
        end
        else if(icode == IPOPQ)
        begin
            valE = 64'd1+valB;
        end
    end

    always@(posedge clk)
    begin
        M_stat <= E_stat;
        M_icode <= E_icode;
        M_cnd <= e_cnd;
        M_valE <= e_valE;
        M_valA <= E_valA;
        M_dstE <= e_dstE;
        M_dstM <= E_dstM;
    end

endmodule