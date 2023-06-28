// FETCH BLOCK

module fetch(clk, PC, icode, ifun, rA, rB, valC, valP, imem_error, instr_valid, hlt);

    input clk;
    input [63:0] PC;
    
    output reg [3:0] icode;
    output reg [3:0] ifun;

    output reg [3:0] rA;
    output reg [3:0] rB;

    output reg [63:0] valC;
    output reg [63:0] valP;

    output reg instr_valid; 
    output reg imem_error;
    output reg hlt;

    reg [0:79] instruction; //Instruction encodings range between 1 and 10 bytes
    reg [7:0] memory[0:1023]; //memory has 256-32 bits words => 1024-8 bits

    reg [0:7] opcode; //operation codes
    reg [0:7] regids; //register IDs

    initial
    begin
        rA = 4'hf;
        rB = 4'hf;
        valC = 64'd0;
        valP = 64'd0;
        hlt = 0;
        instr_valid = 0;
        imem_error = 0;
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

    // irmovq $0x0, %rax
    memory[0]=8'b00110000; //3 0
    memory[1]=8'b00000000; //F rB=0
    memory[2]=8'b00000000;           
    memory[3]=8'b00000000;           
    memory[4]=8'b00000000;           
    memory[5]=8'b00000000;           
    memory[6]=8'b00000000;           
    memory[7]=8'b00000000;           
    memory[8]=8'b00000000;          
    memory[9]=8'b00000000; //V=0

    // irmovq $0x10, %rdx
    memory[10]=8'b00110000; //3 0
    memory[11]=8'b00000010; //F rB=2
    memory[12]=8'b00000000;           
    memory[13]=8'b00000000;           
    memory[14]=8'b00000000;           
    memory[15]=8'b00000000;           
    memory[16]=8'b00000000;           
    memory[17]=8'b00000000;           
    memory[18]=8'b00000000;          
    memory[19]=8'b00010000; //V=16

    // irmovq $0xc, %rbx
    memory[20]=8'b00110000; //3 0
    memory[21]=8'b00000011; //F rB=3
    memory[22]=8'b00000000;           
    memory[23]=8'b00000000;           
    memory[24]=8'b00000000;           
    memory[25]=8'b00000000;           
    memory[26]=8'b00000000;           
    memory[27]=8'b00000000;           
    memory[28]=8'b00000000;          
    memory[29]=8'b00001100; //V=12

    // jmp check
    memory[30]=8'b01110000; //7 fn
    memory[31]=8'b00000000; //Dest
    memory[32]=8'b00000000; //Dest
    memory[33]=8'b00000000; //Dest
    memory[34]=8'b00000000; //Dest
    memory[35]=8'b00000000; //Dest
    memory[36]=8'b00000000; //Dest
    memory[37]=8'b00000000; //Dest
    memory[38]=8'b00100111; //Dest=39

    // check:
        // addq %rax, %rbx 
        memory[39]=8'b01100000; //5 fn
        memory[40]=8'b00000011; //rA=0 rB=3
        // je rbxres  
        memory[41]=8'b01110011; //7 fn=3
        memory[42]=8'b00000000; //Dest
        memory[43]=8'b00000000; //Dest
        memory[44]=8'b00000000; //Dest
        memory[45]=8'b00000000; //Dest
        memory[46]=8'b00000000; //Dest
        memory[47]=8'b00000000; //Dest
        memory[48]=8'b00000000; //Dest
        memory[49]=8'b01111010; //Dest=122
        // addq %rax, %rdx
        memory[50]=8'b01100000; //5 fn
        memory[51]=8'b00000010; //rA=0 rB=2
        // je rdxres 
        memory[52]=8'b01110011; //7 fn=3
        memory[53]=8'b00000000; //Dest
        memory[54]=8'b00000000; //Dest
        memory[55]=8'b00000000; //Dest
        memory[56]=8'b00000000; //Dest
        memory[57]=8'b00000000; //Dest
        memory[58]=8'b00000000; //Dest
        memory[59]=8'b00000000; //Dest
        memory[60]=8'b01111101; //Dest=125
        // jmp loop2 
        memory[61]=8'b01110000; //7 fn=0
        memory[62]=8'b00000000; //Dest
        memory[63]=8'b00000000; //Dest
        memory[64]=8'b00000000; //Dest
        memory[65]=8'b00000000; //Dest
        memory[66]=8'b00000000; //Dest
        memory[67]=8'b00000000; //Dest
        memory[68]=8'b00000000; //Dest
        memory[69]=8'b01000110; //Dest

        // halt
        memory[70]=8'b00000000; // 0 0


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

    // //OPq
    //     memory[32]=8'b01100000; //5 fn
    //     memory[33]=8'b00100011; //rA rB
    
    //     memory[34]=8'b00010000; // 1 0
    //     memory[35]=8'b00010000; // 1 0
    //     memory[36]=8'b00010000; // 1 0

    // //cmovxx
    //     memory[37]=8'b00100000; //2 fn
    //     memory[38]=8'b00000100; //rA rB

    //     memory[39]=8'b00010000; // 1 0
    //     memory[40]=8'b00010000; // 1 0
    //     memory[41]=8'b00010000; // 1 0
    //     memory[42]=8'b00010000; // 1 0
    //     memory[43]=8'b00010000; // 1 0
    //     memory[44]=8'b00010000; // 1 0

    // //halt
    //     memory[45]=8'b00000000; // 0 0

    // // call
    // memory[43]=8'b10000000; //8 0
    // memory[44]=8'b00000000; //Dest
    // memory[45]=8'b00000000; //Dest
    // memory[46]=8'b00000000; //Dest
    // memory[47]=8'b00000000; //Dest
    // memory[48]=8'b00000000; //Dest
    // memory[49]=8'b00000000; //Dest
    // memory[50]=8'b00000000; //Dest
    // memory[51]=8'b00000001; //Dest

    // // ret
    // memory[52]=8'b10010000; // 9 0 

    // // pushq
    // memory[53]=8'b10100000; //A 0
    // memory[54]=8'b00100000; //rA F

    // // popq
    // memory[55]=8'b10110000; //B 0
    // memory[56]=8'b00000000; //rA F

    // // rmmovq
    // memory[12]=8'b01000000; //4 0
    // memory[13]=8'b01010010; //rA rB
    // memory[14]=8'b00000000; //D
    // memory[15]=8'b00000000; //D
    // memory[16]=8'b00000000; //D
    // memory[17]=8'b00000000; //D
    // memory[18]=8'b00000000; //D
    // memory[19]=8'b00000000; //D
    // memory[20]=8'b00000000; //D
    // memory[21]=8'b00000001; //D

    // // mrmovq
    // memory[22]=8'b01010000; //5 0
    // memory[23]=8'b01110010; //rA rB
    // memory[24]=8'b00000000; //D
    // memory[25]=8'b00000000; //D
    // memory[26]=8'b00000000; //D
    // memory[27]=8'b00000000; //D
    // memory[28]=8'b00000000; //D
    // memory[29]=8'b00000000; //D
    // memory[30]=8'b00000000; //D
    // memory[31]=8'b00000001; //D

    // // halt
    // memory[32]=8'b00000000; // 0 0



    end


    always@(posedge clk)
    begin

        if(PC > 64'd1023)
        begin

            imem_error = 1; //invalid address        
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
            end
            else
            begin

                instr_valid = 0;
                
                //halt
                if(icode == IHALT)
                begin

                    hlt = 1;
                    
                    //valP = PC+1
                    valP = PC + 64'd1;

                end
                //nop
                else if (icode == INOP)
                begin

                    //valP = PC+1
                    valP = PC + 64'd1;

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

                end
                //jXX
                else if (icode == IJXX)
                begin

                    //valC <- M8[PC+1]
                    valC = instruction[8:71];
                    
                    //valP <- PC+9
                    valP = PC + 64'd9;

                end
                //call
                else if (icode == ICALL)
                begin

                    //valC <- M8[PC+1]
                    valC = instruction[8:71];
                    
                    //valP <- PC+9
                    valP = PC + 64'd9;

                end
                //ret
                else if (icode == IRET)
                begin

                    //valP <- PC+1
                    valP = PC + 64'd1;

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

                end

            end

        end    

    end 

endmodule