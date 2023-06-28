// DECODE BLOCK

module decode(clk, D_icode, D_ifun, D_rA, D_rB, D_valC, D_valP, D_stat, e_dstE, M_dstM, M_dstE, W_dstM, W_dstE, e_valE, m_valM, M_valE, W_valM, W_valE, E_bubble, E_icode, E_ifun, E_valA, E_valB, E_valC, E_dstE, E_dstM, E_srcA, E_srcB, E_stat, srcA, srcB, valA, valB);

    input clk;
    
    input [3:0] D_icode;
    input [3:0] D_ifun;

    input [3:0] D_rA;
    input [3:0] D_rB;  

    input [63:0] D_valC;
    input [63:0] D_valP;

    input [1:0] D_stat;  //AOK|HLT|ADR|INS

    input [3:0] e_dstE, M_dstM, M_dstE, W_dstM, W_dstE;
    input [63:0] e_valE, m_valM, M_valE, W_valM, W_valE;

    input E_bubble;

    output reg [3:0] E_icode;
    output reg [3:0] E_ifun;

    output reg [63:0] E_valA;
    output reg [63:0] E_valB;
    output reg [63:0] E_valC;

    output reg [3:0] E_dstE;
    output reg [3:0] E_dstM;
    output reg [3:0] E_srcA;
    output reg [3:0] E_srcB;

    output reg [1:0] E_stat; //AOK|HLT|ADR|INS

    output reg [63:0] valA;
    output reg [63:0] valB;
    output reg [3:0] srcA, srcB;
    reg [3:0] dstE, dstM;

    reg [63:0] Reg_File[0:14];


    // instruction codes
    // Constant values used in HCL descriptions.
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

    // registers
    parameter Register_rax = 4'd0;
    parameter Register_rcx = 4'd1;
    parameter Register_rdx = 4'd2;
    parameter Register_rbx = 4'd3;
    parameter RRSP         = 4'd4;
    parameter Register_rbp = 4'd5;
    parameter Register_rsi = 4'd6;
    parameter Register_rdi = 4'd7;
    parameter Register_r8  = 4'd8;
    parameter Register_r9  = 4'd9;
    parameter Register_r10 = 4'd10;
    parameter Register_r11 = 4'd11;
    parameter Register_r12 = 4'd12;
    parameter Register_r13 = 4'd13;
    parameter Register_r14 = 4'd14;
    parameter RNONE        = 4'd15;

    always@(posedge clk)
    begin

        $readmemh("reg_file.txt", Reg_File);
        
    end

    always@(*)
    begin

        
            if (D_icode == IRRMOVQ)
            begin

                srcA = D_rA;
                srcB = RNONE;
                dstE = D_rB;
                dstM = RNONE;
                // valA ← R[rA]
                valA = Reg_File[D_rA];

            end
            else if(D_icode == IIRMOVQ)
            begin

                dstE = D_rB;
                dstM = RNONE;
                srcA = RNONE;
                srcB = RNONE;

            end
            // rmmovq
            else if (D_icode == IRMMOVQ)
            begin

                srcA = D_rA;
                srcB = RNONE;
                dstE = D_rB;
                dstM = RNONE;

                // valA ← R[rA]
                valA = Reg_File[D_rA];
                
                // valB ← R[rB]
                valB = Reg_File[D_rB];

            end
            // mrmovq
            else if (D_icode == IMRMOVQ)
            begin
                
                srcA = RNONE;
                srcB = D_rB;
                dstM = D_rA; 
                dstE = RNONE;               

                // valB ← R[rB]
                valB = Reg_File[D_rB];

            end
            //Opq
            else if (D_icode == IOPQ)
            begin

                srcA = D_rA;
                srcB = D_rB;
                dstE = D_rB;
                dstM = RNONE;               

                // valA ← R[rA]
                valA = Reg_File[D_rA];
                
                // valB ← R[rB]
                valB = Reg_File[D_rB];    

            end
            else if (D_icode == ICALL)
            begin

                srcA = RNONE;
                srcB = RRSP;
                dstE = RRSP;
                dstM = RNONE;               

                //valB ← R[ %rsp ]
                valB = Reg_File[RRSP];    

            end
            //ret
            else if (D_icode == IRET)
            begin

                srcA = RRSP;
                srcB = RRSP;
                dstE = RRSP;
                dstM = RNONE;               

                // valA ← R[ %rsp ]
                valA = Reg_File[RRSP];

                // valB ← R[ %rsp ]
                valB = Reg_File[RRSP];

            end
            //pushq
            else if (D_icode == IPUSHQ)
            begin

                srcA = D_rA;
                srcB = RRSP;
                dstE = RRSP;
                dstM = RNONE;               

                // valA ← R[rA]
                valA = Reg_File[D_rA];

                // valB ← R[ %rsp ]
                valB = Reg_File[RRSP];

            end
            //popq
            else if (D_icode == IPOPQ)
            begin

                srcA = RRSP;
                srcB = RRSP;
                dstE = RRSP;
                dstM = D_rA;

                // valA ← R[ %rsp ]
                valA = Reg_File[RRSP];

                // valB ← R[ %rsp ]
                valB = Reg_File[RRSP];   

            end
            else
            begin

                srcA = RNONE;
                srcB = RNONE;
                dstE = RNONE;
                dstM = RNONE;

            end

    end

    always@(*)
    begin

        //Forwarding logic for valA
            if(D_icode == ICALL || D_icode == IJXX)
            begin
                valA = D_valP;
            end
            else if (srcA == e_dstE && srcA != RNONE)
            begin
                valA = e_valE;
            end
            else if (srcA == M_dstM && srcA != RNONE)
            begin
                valA = m_valM;
            end
            else if (srcA == M_dstE && srcA != RNONE)
            begin
                valA = M_valE;
            end
            else if (srcA == W_dstM && srcA != RNONE)
            begin
                valA = W_valM;
            end
            else if (srcA == W_dstE && srcA != RNONE)
            begin
                valA = W_valE;
            end
    end
        
    always@(*)
    begin
            //Forwarding logic for valB
            if(srcB == e_dstE && srcB != RNONE)
            begin
                valB = e_valE;
            end
            else if(srcB == M_dstM && srcB != RNONE)
            begin
                valB = m_valM;
            end
            else if(srcB == M_dstE && srcB != RNONE)
            begin
                valB = M_valE;
            end
            else if(srcB == W_dstM && srcB != RNONE)
            begin
                valB = W_valM;
            end
            else if(srcB == W_dstE && srcB != RNONE)
            begin
                valB = W_valE;
            end

    end

    always@(posedge clk)
    begin

        if(E_bubble == 1)
        begin
            E_icode <= 4'b0001; //nop
            E_ifun <= 4'b0000;
            E_valA <= 4'b0000;
            E_valB <= 4'b0000;
            E_valC <= 4'b0000;
            E_srcA <= RNONE;
            E_srcB <= RNONE;
            E_dstE <= RNONE;
            E_dstM <= RNONE;
            E_stat <= 2'd0;
        end
        else
        begin
            E_icode <= D_icode; 
            E_ifun <= D_ifun;
            E_valA <= valA;
            E_valB <= valB;
            E_valC <= D_valC;
            E_srcA <= srcA;
            E_srcB <= srcB;
            E_dstE <= dstE;
            E_dstM <= dstM;
            E_stat <= D_stat;
        end
    end

endmodule
