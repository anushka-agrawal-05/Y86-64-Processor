// WRITE BACK BLOCK

module write_back(clk, W_icode, W_dstE, W_dstM, W_valE, W_valM);

    input clk;
    input [3:0] W_icode;

    input [3:0] W_dstE;
    input [3:0] W_dstM;

    input [63:0] W_valE;
    input [63:0] W_valM;


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
        //rrmovq and  cmovXX
        if (W_icode == IRRMOVQ)
        begin

            // R[rB] ← valE
            Reg_File[W_dstE] = W_valE;  

            $writememh("reg_file.txt", Reg_File);           

        end
        //irmovq
        else if (W_icode == IIRMOVQ)
        begin

            // R[rB] ← valE
            Reg_File[W_dstE] = W_valE; 

            $writememh("reg_file.txt", Reg_File);           

        end
        // mrmovq
        else if (W_icode == IMRMOVQ)
        begin

            // R[rA] ← valM
            Reg_File[W_dstM] = W_valM;

            $writememh("reg_file.txt", Reg_File);
                
        end
        //Opq
        else if (W_icode == IOPQ)
        begin
            
            // R[rB] ← valE
            Reg_File[W_dstE] = W_valE;   

            $writememh("reg_file.txt", Reg_File);             

        end
        //call
        else if (W_icode == ICALL)
        begin

            // R[ %rsp ] ← valE
            Reg_File[W_dstE] = W_valE;  

            $writememh("reg_file.txt", Reg_File);    

        end
        //ret
        else if (W_icode == IRET)
        begin

            // R[ %rsp ] ← valE
            Reg_File[W_dstE] = W_valE; 

            $writememh("reg_file.txt", Reg_File);   

        end
        //pushq
        else if (W_icode == IPUSHQ)
        begin
            
            // R[ %rsp ] ← valE
            Reg_File[W_dstE] = W_valE; 

            $writememh("reg_file.txt", Reg_File);                  

        end
        //popq
        else if (W_icode == IPOPQ)
        begin

            // R[ %rsp ] ← valE
            Reg_File[W_dstE] = W_valE;

            // R[rA] ← valM
            Reg_File[W_dstM] = W_valM; 

            $writememh("reg_file.txt", Reg_File);

        end
    end
endmodule