//MEMORY BLOCK

module memory(clk, icode, valA, valE, valP, valM, dmem_error, datamem, memory_address);

    input clk;
    input[3:0] icode;
    input [63:0] valA;
    input [63:0] valE;
    input [63:0] valP;
    output reg [63:0] valM;
    output reg dmem_error;
    output reg [63:0] datamem;

    //Data Memory
    reg [63:0] data_memory [1023:0];

    output reg [63:0] memory_address;

    // Initialization
    initial 
    begin
        valM = 64'd0;
        dmem_error = 1'b0;
        memory_address = 1'b0;
    end

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

    // Hardcoding Data Memory
    initial
    begin
        data_memory[0] = 64'd0;
        data_memory[1] = 64'd1;
        data_memory[2] = 64'd2;
        data_memory[3] = 64'd3;
        data_memory[4] = 64'd4;
        data_memory[5] = 64'd5;
        data_memory[6] = 64'd6;
        data_memory[7] = 64'd7;
        data_memory[8] = 64'd8;
        data_memory[9] = 64'd9;
        data_memory[10] = 64'd10;
        data_memory[11] = 64'd11;
        data_memory[12] = 64'd12;
        data_memory[13] = 64'd13;
        data_memory[14] = 64'd14;
        data_memory[15] = 64'd15;
        data_memory[16] = 64'd16;
        data_memory[17] = 64'd17;
        data_memory[18] = 64'd18;
        data_memory[19] = 64'd19;
        data_memory[20] = 64'd20;
    end

    always@(*)
    begin
        if(clk==1)
        begin
            if(icode == IRMMOVQ)
            begin
                memory_address = valE;
                data_memory[valE] = valA;
            end
            else if (icode == IMRMOVQ)
            begin
                memory_address = valE;
                valM = data_memory[valE];
            end
            else if (icode == ICALL)
            begin
                memory_address = valE;
                data_memory[valE] = valP;
            end
            else if (icode == IRET)
            begin
                memory_address = valA;
                valM = data_memory[valA];
            end
            else if (icode == IPUSHQ) 
            begin
                memory_address = valE;
                data_memory[valE] = valA;
            end
            else if (icode == IPOPQ) 
            begin
                memory_address = valA;
                valM = data_memory[valA];
		    end
            datamem = data_memory[valE];

            // if(memory_address > 64'd1023)
            // begin
            //     dmem_error = 1'd1;
            // end

        end
    end

    always@(*)
    begin
        if(clk==0)
        begin
            if(memory_address>64'd1023)
            begin
                dmem_error = 1'd1;
            end
        end
    end

endmodule