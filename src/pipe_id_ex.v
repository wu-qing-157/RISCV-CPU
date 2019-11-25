`include "define.v"

module pipe_id_ex(
    input wire clock,
    input wire reset,

    input wire [`StallBus] stall,

    input wire [`AluSelBus] alusel_i,
    input wire [`AluOpBus] aluop_i,
    input wire [`RegBus] op1_i,
    input wire [`RegBus] op2_i,
    input wire [`RegBus] link_addr_i,
    input wire write_i,
    input wire [`RegAddrBus] regw_addr_i,
    input wire [`RegBus] mem_offset_i,

    output reg [`AluSelBus] alusel_o,
    output reg [`AluOpBus] aluop_o,
    output reg [`RegBus] op1_o,
    output reg [`RegBus] op2_o,
    output reg [`RegBus] link_addr_o,
    output reg write_o,
    output reg [`RegAddrBus] regw_addr_o,
    output reg [`RegBus] mem_offset_o
);

    always @(posedge clock) begin
        if (reset || (stall[2] && !stall[3])) begin
            alusel_o <= 0;
            aluop_o <= 0;
            op1_o <= 0;
            op2_o <= 0;
            link_addr_o <= 0;
            write_o <= 0;
            regw_addr_o <= 0;
            mem_offset_o <= 0;
        end else if (!stall[2]) begin
            alusel_o <= alusel_i;
            aluop_o <= aluop_i;
            op1_o <= op1_i;
            op2_o <= op2_i;
            link_addr_o <= link_addr_i;
            write_o <= write_i;
            regw_addr_o <= regw_addr_i;
            mem_offset_o <= mem_offset_i;
        end
    end

endmodule
