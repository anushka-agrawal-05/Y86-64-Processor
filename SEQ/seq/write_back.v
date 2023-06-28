// WRITE BACK BLOCK

module write_back(clk, icode, rA, rB, cnd, valE, valM);

    input clk;
    input [3:0] icode;
    input [3:0] rA;
    input [3:0] rB;
    input cnd;
    input [63:0] valE;
    input [63:0] valM;

    reg [3:0] dstE;
    reg [3:0] dstM;

    reg [63:0] Reg_File[0:14];

    integer i;

    initial
    begin
        dstE = 4'd15;
        dstM = 4'd15;
    end

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


    always@(*)
    begin
        if(clk==1)
            $readmemh("reg_file.txt", Reg_File);
        
    end

    always@(*)
    begin
        if(clk == 0)
        begin
            $writememh("reg_file.txt", Reg_File);
        end
    end

    always@(negedge clk)
    begin

        //rrmovq and  cmovXX
        if (icode == IRRMOVQ && cnd == 1)
        begin

            // R[rB] ← valE
            dstE = rB;
            Reg_File[dstE] = valE;             

        end
        //irmovq
        else if (icode == IIRMOVQ)
        begin

            // R[rB] ← valE
            dstE = rB;
            Reg_File[dstE] = valE;            

        end
        // mrmovq
        else if (icode == IMRMOVQ)
        begin

            // R[rA] ← valM
            dstM = rA;
            Reg_File[dstM] = valM;
                
        end
        //Opq
        else if (icode == IOPQ)
        begin
            
            // R[rB] ← valE
            dstE = rB;
            Reg_File[dstE] = valE;                

        end
        //call
        else if (icode == ICALL)
        begin

            // R[ %rsp ] ← valE
            dstE = RRSP;
            Reg_File[dstE] = valE;      

        end
        //ret
        else if (icode == IRET)
        begin

            // R[ %rsp ] ← valE
            dstE = RRSP;
            Reg_File[dstE] = valE;    

        end
        //pushq
        else if (icode == IPUSHQ)
        begin
            
            // R[ %rsp ] ← valE
            dstE = RRSP;
            Reg_File[dstE] = valE;                   

        end
        //popq
        else if (icode == IPOPQ)
        begin

            // R[ %rsp ] ← valE
            dstE = RRSP;
            Reg_File[dstE] = valE;

            // R[rA] ← valM
            dstM = rA;   
            Reg_File[dstM] = valM; 

        end

    end


endmodule
