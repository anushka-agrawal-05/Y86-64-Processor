// DECODE BLOCK

module decode(clk, icode, rA, rB, valA, valB);

    input clk;
    input [3:0] icode;
    input [3:0] rA;
    input [3:0] rB;

    output reg [63:0] valA;
    output reg [63:0] valB;

    reg [63:0] Reg_File[0:14];

    integer i;

    initial
    begin
        valA = 64'd0;
        valB = 64'd0;
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

    always@(posedge clk)
    begin

        $readmemh("reg_file.txt", Reg_File);
        
    end

    always@(*)
    begin

        if(clk == 1)
        begin
        
            if (icode == IRRMOVQ)
            begin

                // valA ← R[rA]
                valA = Reg_File[rA];

            end
            // rmmovq
            else if (icode == IRMMOVQ)
            begin

                // valA ← R[rA]
                valA = Reg_File[rA];
                
                // valB ← R[rB]
                valB = Reg_File[rB];

            end
            // mrmovq
            else if (icode == IMRMOVQ)
            begin

                // valB ← R[rB]
                valB = Reg_File[rB];

            end
            //Opq
            else if (icode == IOPQ)
            begin

                // valA ← R[rA]
                valA = Reg_File[rA];
                
                // valB ← R[rB]
                valB = Reg_File[rB];    

            end
            else if (icode == ICALL)
            begin

                //valB ← R[ %rsp ]
                valB = Reg_File[RRSP];    

            end
            //ret
            else if (icode == IRET)
            begin

                // valA ← R[ %rsp ]
                valA = Reg_File[RRSP];

                // valB ← R[ %rsp ]
                valB = Reg_File[RRSP];

            end
            //pushq
            else if (icode == IPUSHQ)
            begin

                // valA ← R[rA]
                valA = Reg_File[rA];

                // valB ← R[ %rsp ]
                valB = Reg_File[RRSP];

            end
            //popq
            else if (icode == IPOPQ)
            begin

                // valA ← R[ %rsp ]
                valA = Reg_File[RRSP];

                // valB ← R[ %rsp ]
                valB = Reg_File[RRSP];   

            end
        end
    end

endmodule
