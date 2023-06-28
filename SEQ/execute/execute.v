//EXECUTE BLOCK

`include "alu.v"

module execute(clk, icode, ifun, valA, valB, valC, valE, cnd);

    input clk;
    input [3:0] icode;
    input [3:0] ifun;
    input [63:0] valA;
    input [63:0] valB;
    input [63:0] valC;

    output reg [63:0] valE;
    output reg cnd;

    // Condition Code [ZF, SF, OF]
    reg [2:0] CC;
    reg zf;
    reg sf;
    reg of;

    // reg [63:0] aluA, aluB;
    wire signed [63:0]ans;
    reg signed [63:0] ans_;
    wire [2:0] conCode;
    reg [2:0] CC_;
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
        if(clk == 1)
        begin
            zf = conCode[2];
            sf = conCode[1];
            of = conCode[0];
        end
    end

    alu_ uut(aluA, aluB, op, ans, conCode);


    always @(*)
    begin
        if(clk ==1)
        begin
            if(icode == IRRMOVQ)
            begin
                valE = valA;
                if(ifun == 4'd0) // unconditional
                begin
                    cnd = 1;
                end
                else if(ifun == 4'd1) // less than equal to
                begin
                    cnd = ((sf^of)| zf);
                end
                else if(ifun == 4'd2) // less than 
                begin
                    cnd = (sf^of);
                end
                else if(ifun == 4'd3) // equal to
                begin
                    cnd = zf;
                end
                else if(ifun == 4'd4) // not equal to
                begin
                    cnd = ~zf;
                end
                else if(ifun == 4'd5) // greater than equal to
                begin
                    cnd = ~(sf^of);
                end
                else if(ifun == 4'd6) // greater than 
                begin
                    cnd = ((~(sf^of))&~zf);
                end
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
    end

endmodule
