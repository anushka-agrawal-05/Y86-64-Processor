// FETCH BLOCK

module fetch(clk, F_predPC, M_icode, M_cnd, M_valA, W_icode, W_valM, F_stall, D_stall, D_bubble, f_predPC, D_icode, D_ifun, D_rA, D_rB, D_valC, D_valP, D_stat);

    input clk;
    input [63:0] F_predPC;

    input [3:0] M_icode;
    input M_cnd;
    input [63:0] M_valA;

    input [3:0] W_icode;
    input [63:0] W_valM;   

    input F_stall, D_stall, D_bubble;

    output reg [63:0] f_predPC;

    output reg [3:0] D_icode;
    output reg [3:0] D_ifun;

    output reg [3:0] D_rA;
    output reg [3:0] D_rB;

    output reg [63:0] D_valC;
    output reg [63:0] D_valP;

    output reg [1:0] D_stat;  //AOK|HLT|ADR|INS

    reg [63:0] PC;
    
    reg [3:0] icode;
    reg [3:0] ifun;

    reg [3:0] rA;
    reg [3:0] rB;

    reg [63:0] valC;
    reg [63:0] valP;

    reg [1:0] stat;  //AOK|HLT|ADR|INS

    reg instr_valid; 
    reg imem_error;

    reg [0:79] instruction; //Instruction encodings range between 1 and 10 bytes
    reg [7:0] memory[0:1023];//memory has 256-32 bits words => 1024-8 bits

    reg [0:7] opcode; //operation codes
    reg [0:7] regids; //register IDs

    initial
    begin
        rA = 4'hf;
        rB = 4'hf;
        valC = 64'd0;
        valP = 64'd0;
        instr_valid = 0;
        imem_error = 0;
        stat = 2'd0;
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

    initial 
    begin

// // code 1:

//     // irmovq $0x1, %rax
//     memory[0]=8'b00110000; //3 0
//     memory[1]=8'b00000000; //F rB=0
//     memory[2]=8'b00000000;           
//     memory[3]=8'b00000000;           
//     memory[4]=8'b00000000;           
//     memory[5]=8'b00000000;           
//     memory[6]=8'b00000000;           
//     memory[7]=8'b00000000;           
//     memory[8]=8'b00000000;          
//     memory[9]=8'b00000001; //V=0

//     // irmovq $0x10, %rdx
//     memory[10]=8'b00110000; //3 0
//     memory[11]=8'b00000010; //F rB=2
//     memory[12]=8'b00000000;           
//     memory[13]=8'b00000000;           
//     memory[14]=8'b00000000;           
//     memory[15]=8'b00000000;           
//     memory[16]=8'b00000000;           
//     memory[17]=8'b00000000;           
//     memory[18]=8'b00000000;          
//     memory[19]=8'b00010000; //V=16

//     // irmovq $0xc, %rbx
//     memory[20]=8'b00110000; //3 0
//     memory[21]=8'b00000011; //F rB=3
//     memory[22]=8'b00000000;           
//     memory[23]=8'b00000000;           
//     memory[24]=8'b00000000;           
//     memory[25]=8'b00000000;           
//     memory[26]=8'b00000000;           
//     memory[27]=8'b00000000;           
//     memory[28]=8'b00000000;          
//     memory[29]=8'b00001100; //V=12

//     // jmp check
//     memory[30]=8'b01110000; //7 fn
//     memory[31]=8'b00000000; //Dest
//     memory[32]=8'b00000000; //Dest
//     memory[33]=8'b00000000; //Dest
//     memory[34]=8'b00000000; //Dest
//     memory[35]=8'b00000000; //Dest
//     memory[36]=8'b00000000; //Dest
//     memory[37]=8'b00000000; //Dest
//     memory[38]=8'b00100111; //Dest=39

//     // check:
//         // addq %rax, %rbx 
//         memory[39]=8'b01100000; //5 fn
//         memory[40]=8'b00000011; //rA=0 rB=3

//         // je rbxres  
//         memory[41]=8'b01110011; //7 fn=3
//         memory[42]=8'b00000000; //Dest
//         memory[43]=8'b00000000; //Dest
//         memory[44]=8'b00000000; //Dest
//         memory[45]=8'b00000000; //Dest
//         memory[46]=8'b00000000; //Dest
//         memory[47]=8'b00000000; //Dest
//         memory[48]=8'b00000000; //Dest
//         memory[49]=8'b01111010; //Dest=122
//         // addq %rax, %rdx
//         memory[50]=8'b01100000; //5 fn
//         memory[51]=8'b00000010; //rA=0 rB=2
//         // je rdxres 
//         memory[52]=8'b01110011; //7 fn=3
//         memory[53]=8'b00000000; //Dest
//         memory[54]=8'b00000000; //Dest
//         memory[55]=8'b00000000; //Dest
//         memory[56]=8'b00000000; //Dest
//         memory[57]=8'b00000000; //Dest
//         memory[58]=8'b00000000; //Dest
//         memory[59]=8'b00000000; //Dest
//         memory[60]=8'b01111101; //Dest=125
//         // jmp loop2 
//         memory[61]=8'b01110000; //7 fn=0
//         memory[62]=8'b00000000; //Dest
//         memory[63]=8'b00000000; //Dest
//         memory[64]=8'b00000000; //Dest
//         memory[65]=8'b00000000; //Dest
//         memory[66]=8'b00000000; //Dest
//         memory[67]=8'b00000000; //Dest
//         memory[68]=8'b00000000; //Dest
//         memory[69]=8'b01000110; //Dest

//         // halt
//         memory[70]=8'b00000000; // 0 0


    // // loop2:
    //     // rrmovq %rdx, %rsi 
    //     memory[70]=8'b00100000; //2 fn=0
    //     memory[71]=8'b00100110; //rA=2 rB=6
    //     // rrmovq %rbx, %rdi
    //     memory[72]=8'b00100000; //2 fn=0
    //     memory[73]=8'b00110111; //rA=3 rB=7
    //     // subq %rbx, %rsi
    //     memory[74]=8'b01100001; //5 fn=1
    //     memory[75]=8'b00110110; //rA=3 rB=6
    //     // jge ab1  
    //     memory[76]=8'b01110101; //7 fn=5
    //     memory[77]=8'b00000000; //Dest
    //     memory[78]=8'b00000000; //Dest
    //     memory[79]=8'b00000000; //Dest
    //     memory[80]=8'b00000000; //Dest
    //     memory[81]=8'b00000000; //Dest
    //     memory[82]=8'b00000000; //Dest
    //     memory[83]=8'b00000000; //Dest
    //     memory[84]=8'b01100000; //Dest=96
           
    //     // subq %rdx, %rdi 
    //     memory[85]=8'b01100001; //5 fn
    //     memory[86]=8'b00100111; //rA=2 rB=7
    //     // jge ab2
    //     memory[87]=8'b01110101; //7 fn=5
    //     memory[88]=8'b00000000; //Dest
    //     memory[89]=8'b00000000; //Dest
    //     memory[90]=8'b00000000; //Dest
    //     memory[91]=8'b00000000; //Dest
    //     memory[92]=8'b00000000; //Dest
    //     memory[93]=8'b00000000; //Dest
    //     memory[94]=8'b00000000; //Dest
    //     memory[95]=8'b01101101; //Dest=109

    // // ab1:
    //     // rrmovq %rbx, %rdx
    //     memory[96]=8'b00100000; //2 fn=0
    //     memory[97]=8'b00110010; //rA=3 rB=2
    //     // rrmovq %rsi, %rbx
    //     memory[98]=8'b00100000; //2 fn=0
    //     memory[99]=8'b01100011; //rA=6 rB=3
    //     // jmp check
    //     memory[100]=8'b01110000; //7 fn=0
    //     memory[101]=8'b00000000; //Dest
    //     memory[102]=8'b00000000; //Dest
    //     memory[103]=8'b00000000; //Dest
    //     memory[104]=8'b00000000; //Dest
    //     memory[105]=8'b00000000; //Dest
    //     memory[106]=8'b00000000; //Dest
    //     memory[107]=8'b00000000; //Dest
    //     memory[108]=8'b00100111; //Dest=39

    //     // //  halt
    //         memory[109]=8'b00000000; // 0 0

    // // ab2:
    //     // rrmovq %rbx, %rdx
    //     // memory[109]=8'b00100000; //2 fn=0
    //     memory[110]=8'b00110010; //rA=3 rB=2
    //     // rrmovq %rdi, %rbx
    //     memory[111]=8'b00100000; //2 fn=0
    //     memory[112]=8'b01110011; //rA=7 rB=3
    //     // jmp check
    //     memory[113]=8'b01110000; //7 fn=0
    //     memory[114]=8'b00000000; //Dest
    //     memory[115]=8'b00000000; //Dest
    //     memory[116]=8'b00000000; //Dest
    //     memory[117]=8'b00000000; //Dest
    //     memory[118]=8'b00000000; //Dest
    //     memory[119]=8'b00000000; //Dest
    //     memory[120]=8'b00000000; //Dest
    //     memory[121]=8'b00100111; //Dest=39

    // // rbxres:
    //     // rrmovq %rdx, %rcx
    //     memory[122]=8'b00100000; //2 fn=0
    //     memory[123]=8'b00100001; //rA=2 rB=1
    //     // halt
    //     memory[124]=8'b00000000;

    // // rdxres:
    //     // rrmovq %rbx, %rcx
    //     memory[125]=8'b00100000; //2 fn=0
    //     memory[126]=8'b00110001; //rA=3 rB=1
    //     // halt
    //     memory[127]=8'b00000000;

//     //OPq
//         memory[32]=8'b01100000; //5 fn
//         memory[33]=8'b00100011; //rA rB
    
//         memory[34]=8'b00010000; // 1 0
//         memory[35]=8'b00010000; // 1 0
//         memory[36]=8'b00010000; // 1 0

//     //cmovxx
//         memory[37]=8'b00100000; //2 fn
//         memory[38]=8'b00000100; //rA rB

//         memory[39]=8'b00010000; // 1 0
//         memory[40]=8'b00010000; // 1 0
//         memory[41]=8'b00010000; // 1 0
//         memory[42]=8'b00010000; // 1 0
//         memory[43]=8'b00010000; // 1 0
//         memory[44]=8'b00010000; // 1 0

//     //halt
//         memory[45]=8'b00000000; // 0 0

//  code 2:
    // // irmovq stack %rsp
    //     memory[0]=8'h30; //3 0
    //     memory[1]=8'hF4; //F rB=0
    //     memory[2]=8'h00;           
    //     memory[3]=8'h00;           
    //     memory[4]=8'h00;           
    //     memory[5]=8'h00;           
    //     memory[6]=8'h00;           
    //     memory[7]=8'h00;           
    //     memory[8]=8'h03;          
    //     memory[9]=8'hff; //V=1023

    // // call main
    //     memory[10]=8'h80; //8 0
    //     memory[11]=8'h00;
    //     memory[12]=8'h00;
    //     memory[13]=8'h00;
    //     memory[14]=8'h00;
    //     memory[15]=8'h00;
    //     memory[16]=8'h00;
    //     memory[17]=8'h00;
    //     memory[18]=8'h14;

    // // halt
    //     memory[19]=8'h00; //0 0

    // //main:

    // // irmovq $0x10 %rdi
    //     memory[20]=8'h30; //3 0
    //     memory[21]=8'hF7; //F rB=7
    //     memory[22]=8'h00;           
    //     memory[23]=8'h00;           
    //     memory[24]=8'h00;           
    //     memory[25]=8'h00;           
    //     memory[26]=8'h00;           
    //     memory[27]=8'h00;           
    //     memory[28]=8'h00;          
    //     memory[29]=8'h10; //V=16
    // // irmovq $0xc %rsi
    //     memory[30]=8'h30; //3 0
    //     memory[31]=8'hF6; //F rB=6
    //     memory[32]=8'h00;           
    //     memory[33]=8'h00;           
    //     memory[34]=8'h00;           
    //     memory[35]=8'h00;           
    //     memory[36]=8'h00;           
    //     memory[37]=8'h00;           
    //     memory[38]=8'h00;          
    //     memory[39]=8'h0c; //V=12
    // // call gcd
    //     memory[40]=8'h80; // 8 0
    //     memory[41]=8'h00;
    //     memory[42]=8'h00;
    //     memory[43]=8'h00;
    //     memory[44]=8'h00;
    //     memory[45]=8'h00;
    //     memory[46]=8'h00;
    //     memory[47]=8'h00;
    //     memory[48]=8'h32;
    // // ret
    //         memory[49]=8'h90; // 9 0

    // // gcd(%rdx,%rbx)
    // // swap:
    // // pushq
    //     memory[50]=8'hA0; //3 0
    //     memory[51]=8'h7f; //F rB=0

    // // pushq
    //     memory[52]=8'hA0;           
    //     memory[53]=8'h6F;       

    // // popq
    //     memory[54]=8'hB0;           
    //     memory[55]=8'h7f; 

    // // popq          
    //     memory[56]=8'hb0;           
    //     memory[57]=8'h6f;           

    //     // ret
    //     memory[58]=8'h90; // 9 0



// code3:
    // irmovq $128 %rdx
        memory[0] = 8'h30; 
        memory[1] = 8'hf2; // F rb=2
        memory[2] = 8'h00;           
        memory[3] = 8'h00;           
        memory[4] = 8'h00;           
        memory[5] = 8'h00;           
        memory[6] = 8'h00;           
        memory[7] = 8'h00;           
        memory[8] = 8'h00;          
        memory[9] = 8'h80; //V=128

    // irmovq $3 %rcx
        memory[10] = 8'h30; 
        memory[11] = 8'hf1; // F rb=1
        memory[12] = 8'h00;           
        memory[13] = 8'h00;           
        memory[14] = 8'h00;           
        memory[15] = 8'h00;           
        memory[16] = 8'h00;           
        memory[17] = 8'h00;           
        memory[18] = 8'h00;          
        memory[19] = 8'h03; //V=3

    // rmmovq %rcx 0(%rdx)
        memory[20] = 8'h40; 
        memory[21] = 8'h12; // rA= 1 rb=2;
        memory[22] = 8'h00;           
        memory[23] = 8'h00;           
        memory[24] = 8'h00;           
        memory[25] = 8'h00;           
        memory[26] = 8'h00;           
        memory[27] = 8'h00;           
        memory[28] = 8'h00;          
        memory[29] = 8'h00; //D=0

    // irmovq $10 %rbx
        memory[30] = 8'h30; 
        memory[31] = 8'hf3; // F rb=3
        memory[32] = 8'h00;           
        memory[33] = 8'h00;           
        memory[34] = 8'h00;           
        memory[35] = 8'h00;           
        memory[36] = 8'h00;           
        memory[37] = 8'h00;           
        memory[38] = 8'h00;          
        memory[39] = 8'h0a; //V=10

    // mrmovq 0(%rdx) %rax
        memory[40] = 8'h50; 
        memory[41] = 8'h02; // rA= 0 rb=2;
        memory[42] = 8'h00;           
        memory[43] = 8'h00;           
        memory[44] = 8'h00;           
        memory[45] = 8'h00;           
        memory[46] = 8'h00;           
        memory[47] = 8'h00;           
        memory[48] = 8'h00;          
        memory[49] = 8'h00; //D=0

    // addq %rbx %rax
        memory[50]=8'h60; 
        memory[51]=8'h30; //rA=3 rB=0

    //halt
        memory[52]=8'b00000000;

    end


    always@(*)
    begin

        if(M_icode == IJXX && M_cnd == 0)
        begin
            PC = M_valA;
        end
        else if (W_icode == IRET)
        begin
            PC= W_valM;
        end
        else
        begin
            PC = F_predPC;
        end

    end

    always@(*)
    begin

        if(PC > 64'd1023)
        begin

            imem_error = 1; //invalid address   
            stat = 2'd2;     
        end
        else
        begin

            imem_error = 0;

            //Instruction encodings range between 1 and 10 bytes
            instruction = {memory[PC], memory[PC+64'd1], memory[PC+64'd2], memory[PC+64'd3], memory[PC+64'd4], memory[PC+64'd5], memory[PC+64'd6], memory[PC+64'd7], memory[PC+64'd8], memory[PC+64'd9]}; 
    
            //An instruction consists of a 1-byte instruction specifier, 1-byte register specifier, and an 8-byte constant word.

            // icode:ifun = M1[PC]
            opcode = instruction[0:7];
            icode = opcode[0:3];
            ifun = opcode[4:7];


            if(icode < 4'd0 || icode > 4'd11)
            begin

                instr_valid = 1; //invalid instruction
                stat = 2'd3;
            end
            else
            begin

                instr_valid = 0;
                
                //halt
                if(icode == IHALT)
                begin

                    stat = 2'd1;
                    
                    //valP = PC+1
                    valP = PC + 64'd1;
                    f_predPC = valP;

                end
                //nop
                else if (icode == INOP)
                begin

                    //valP = PC+1
                    valP = PC + 64'd1;
                    f_predPC = valP;

                end
                //rrmovq and  cmovXX
                else if (icode == IRRMOVQ)
                begin

                    // rA:rB = M1[PC+1]
                    regids = instruction[8:15];
                    rA = regids[0:3];
                    rB = regids[4:7];

                    //valP <- PC+2
                    valP = PC + 64'd2;
                    f_predPC = valP;

                end
                //irmovq
                else if (icode == IIRMOVQ)
                begin

                    // rA:rB = M1[PC+1]
                    regids = instruction[8:15];
                    rA = regids[0:3];
                    rB = regids[4:7];

                    //valC <- M8[PC+2]
                    valC = instruction[16:79];

                    //valP <- PC+10
                    valP = PC + 64'd10;
                    f_predPC = valP;

                end
                // rmmovq
                else if (icode == IRMMOVQ)
                begin

                    // rA:rB = M1[PC+1]
                    regids = instruction[8:15];
                    rA = regids[0:3];
                    rB = regids[4:7];

                    //valC <- M8[PC+2]
                    valC = instruction[16:79];

                    //valP <- PC+10
                    valP = PC + 64'd10;
                    f_predPC = valP;

                end
                // mrmovq
                else if (icode == IMRMOVQ)
                begin

                    // rA:rB = M1[PC+1]
                    regids = instruction[8:15];
                    rA = regids[0:3];
                    rB = regids[4:7];

                    //valC <- M8[PC+2]
                    valC = instruction[16:79];
                    
                    //valP <- PC+10
                    valP = PC + 64'd10;
                    f_predPC = valP;

                end
                //Opq
                else if (icode == IOPQ)
                begin

                    // rA:rB = M1[PC+1]
                    regids = instruction[8:15];
                    rA = regids[0:3];
                    rB = regids[4:7];

                    //valP <- PC+2
                    valP = PC + 64'd2;
                    f_predPC = valP;

                end
                //jXX
                else if (icode == IJXX)
                begin

                    //valC <- M8[PC+1]
                    valC = instruction[8:71];
                    
                    //valP <- PC+9
                    valP = PC + 64'd9;
                    f_predPC = valC;

                end
                //call
                else if (icode == ICALL)
                begin

                    //valC <- M8[PC+1]
                    valC = instruction[8:71];
                    
                    //valP <- PC+9
                    valP = PC + 64'd9;
                    f_predPC = valC;


                end
                //ret
                else if (icode == IRET)
                begin

                    //valP <- PC+1
                    valP = PC + 64'd1;
                    f_predPC = valP;

                end
                //pushq
                else if (icode == IPUSHQ)
                begin

                    // rA:rB = M1[PC+1]
                    regids = instruction[8:15];
                    rA = regids[0:3];
                    rB = regids[4:7];

                    //valP <- PC+2
                    valP = PC + 64'd2;
                    f_predPC = valP;

                end
                //popq
                else if (icode == IPOPQ)
                begin

                    // rA:rB = M1[PC+1]
                    regids = instruction[8:15];
                    rA = regids[0:3];
                    rB = regids[4:7];

                    //valP <- PC+2
                    valP = PC + 64'd2;
                    f_predPC = valP;

                end

            end

        end    

    end 

    always@(posedge clk)
    begin

        if (D_stall == 1)
        begin
        end
        else if(D_bubble == 1)
        begin
            D_icode <= 4'b0001; //nop
            D_ifun <= 4'b0000;
            D_rA <= 4'b0000;
            D_rB <= 4'b0000;
            D_valC <= 64'b0;
            D_valP <= 64'b0;
            D_stat <= 2'd0;
        end
        else
        begin
            D_icode <= icode;
            D_ifun <= ifun;
            D_rA <= rA;
            D_rB <= rB;
            D_valC <= valC;
            D_valP <= valP;
            D_stat <= stat;
        end
    end


endmodule
