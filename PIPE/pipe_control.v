module pipe_control(m_stat, W_stat, D_icode, E_icode, M_icode, d_srcA, d_srcB, E_dstM, e_cnd, F_stall, D_stall, D_bubble, E_bubble, set_cc);

    input [1:0] m_stat, W_stat;
    input [3:0] D_icode, E_icode, M_icode;
    input [3:0] d_srcA, d_srcB, E_dstM;
    input e_cnd;

    output reg F_stall, D_stall, D_bubble, E_bubble;
    output reg set_cc;

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

    always@(*)
    begin
        F_stall = 0;
        D_stall = 0;
        D_bubble =0;
        E_bubble = 0;
        set_cc = 1;

        if((E_icode == IMRMOVQ | E_icode == IPOPQ) & (E_dstM == d_srcA | E_dstM == d_srcB))
        begin
            F_stall = 1;
            D_stall = 1;
            E_bubble = 1;
        end
        else if((E_icode == IJXX & e_cnd==0))
        begin
            D_bubble = 1;
            E_bubble = 1;
        end
        else if(D_icode == IRET | E_icode == IRET | M_icode == IRET)
        begin
            F_stall = 1;
            D_bubble = 1;
        end
        else if(E_icode == 4'h0 | m_stat!=2'b0 | W_stat!=2'b0)
        begin
            set_cc = 0;
        end
    end

endmodule
