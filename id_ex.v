`include "define.v"

module id_ex(
    input wire clock,
    input wire reset,

    input wire[`AluOpBus] id_aluop,
    input wire[`AluSelBus] id_alusel,
    input wire[`RegBus] id_reg1,
    input wire[`RegBus] id_reg2,
    input wire id_write,
    input wire[`RegAddressBus] id_write_address,

    output reg[`AluOpBus] ex_aluop,
    output reg[`AluSelBus] ex_alusel,
    output reg[`RegBus] ex_reg1,
    output reg[`RegBus] ex_reg2,
    output reg ex_write,
    output reg[`RegAddressBus] ex_write_address
);

    always@(posedge clock) begin
        if (reset == 1) begin
            ex_aluop <= 0;
            ex_alusel <= 0;
            ex_reg1 <= 0;
            ex_reg2 <= 0;
            ex_write <= 0;
            ex_write_address <= 0;
        end else begin
            ex_aluop <= id_aluop;
            ex_alusel <= id_alusel;
            ex_reg1 <= id_reg1;
            ex_reg2 <= id_reg2;
            ex_write <= id_write;
            ex_write_address <= id_write_address;
        end
    end


endmodule