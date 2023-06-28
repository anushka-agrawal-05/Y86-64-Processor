module memory(clk, M_stat, M_icode, M_cnd, M_valE, M_valA, M_dstE, M_dstM, W_stat, W_icode, W_valE, W_valM, W_dstE, W_dstM, m_valM, m_stat);

    input clk;
    input [1:0] M_stat;
    input [3:0] M_icode;
    input M_cnd;
    input [63:0] M_valE, M_valA;
    input [3:0] M_dstE, M_dstM;

    output reg [1:0] W_stat;
    output reg [3:0] W_icode;
    output reg [63:0] W_valE, W_valM;
    output reg [3:0] W_dstE, W_dstM;
    output reg [63:0] m_valM;
    output reg [1:0] m_stat;

    reg [63:0] data_memory [1023:0];
    reg [63:0] memory_address;
    reg dmem_error = 0;

    // Initialization  
    initial 
    begin
        m_valM = 64'd0;
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
        data_memory[3] = 64'd10;
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
        data_memory[128] = 64'd4;
    end

    always@(*)
    begin
        if(M_icode == IRMMOVQ)
        begin
            memory_address = M_valE;
            data_memory[M_valE] = M_valA;
        end
        else if (M_icode == IMRMOVQ)
        begin
            memory_address = M_valE;
            m_valM = data_memory[M_valE];
        end
        else if (M_icode == ICALL)
        begin
            memory_address = M_valE;
            data_memory[M_valE] = M_valA;
        end
        else if (M_icode == IRET)
        begin
            memory_address = M_valA;
            m_valM = data_memory[M_valA];
        end
        else if (M_icode == IPUSHQ) 
        begin
            memory_address = M_valE;
            data_memory[M_valE] = M_valA;
        end
        else if (M_icode == IPOPQ) 
        begin
            memory_address = M_valA;
            m_valM = data_memory[M_valA];
        end
    end

    always@(*)
    begin
        if(memory_address>64'd1023)
        begin
            dmem_error = 1'd1;
        end
    end

    always@(*)
    begin
        if(dmem_error==1)
            m_stat = 2'd2;
        else 
            m_stat = M_stat;
    end

    always@(posedge clk)
    // always@(*)
    begin
        W_stat <= m_stat;
        W_icode <= M_icode;
        W_valE <= M_valE;
        W_valM <= m_valM;
        W_dstE <= M_dstE;
        W_dstM <=M_dstM;
    end
endmodule