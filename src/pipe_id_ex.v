`include "define.v"

module pipe_id_ex(
    input wire clock,
    input wire reset,
    input wire discard,

    input wire [3:2] stall,

    input wire [`AluSelBus] alusel_i,
    input wire [`AluOpBus] aluop_i,
    input wire [`RegBus] op1_i,
    input wire [`RegBus] op2_i,
    input wire [`RegBus] link_addr_i,
    input wire write_i,
    input wire [`RegAddrBus] regw_addr_i,
    input wire [`RegBus] mem_offset_i,
    input wire [`MemAddrBus] br_addr_i,
    input wire [`MemAddrBus] br_offset_i,
    input wire prediction_i,
    input wire [`MemAddrBus] pc_i,
    input wire no_prediction_i,

    output reg [`AluSelBus] alusel_o,
    output reg [`AluOpBus] aluop_o,
    output reg [`RegBus] op1_o,
    output reg [`RegBus] op2_o,
    output reg [`RegBus] link_addr_o,
    output reg write_o,
    output reg [`RegAddrBus] regw_addr_o,
    output reg [`RegBus] mem_offset_o,
    output reg [`MemAddrBus] br_addr_o,
    output reg [`MemAddrBus] br_offset_o,
    output reg prediction_o,
    output reg [`MemAddrBus] pc_o,
    output reg no_prediction_o
);

    always @(posedge clock) begin
        if (reset || discard || (stall[2] && !stall[3])) begin
            alusel_o <= 0;
            aluop_o <= 0;
            op1_o <= 0;
            op2_o <= 0;
            link_addr_o <= 0;
            write_o <= 0;
            regw_addr_o <= 0;
            mem_offset_o <= 0;
            br_addr_o <= 0;
            br_offset_o <= 0;
            prediction_o <= 0;
            pc_o <= 0;
            no_prediction_o <= 0;
        end else if (!stall[2] && !stall[3]) begin
            alusel_o <= alusel_i;
            aluop_o <= aluop_i;
            op1_o <= op1_i;
            op2_o <= op2_i;
            link_addr_o <= link_addr_i;
            write_o <= write_i;
            regw_addr_o <= regw_addr_i;
            mem_offset_o <= mem_offset_i;
            br_addr_o <= br_addr_i;
            br_offset_o <= br_offset_i;
            prediction_o <= prediction_i;
            pc_o <= pc_i;
            no_prediction_o <= no_prediction_i;
        end
    end

endmodule
