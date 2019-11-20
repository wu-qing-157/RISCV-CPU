`include "define.v"
`include "pc_reg.v"
`include "if_id.v"
`include "id.v"
`include "id_ex.v"
`include "ex.v"
`include "ex_mem.v"
`include "mem.v"
`include "mem_wb.v"
`include "regfile.v"

module mips(
    input wire clock,
    input wire reset,
    
    output wire rom_ce,
    output wire[`RegBus] rom_address,
    input wire[`RegBus] rom_data
);

    wire[`InstructionAddressBus] pc;

    wire[`InstructionAddressBus] id_pc;
    wire[`InstructionBus] id_instruction;

    wire[`AluOpBus] id_aluop;
    wire[`AluSelBus] id_alusel;
    wire[`RegBus] id_reg1;
    wire[`RegBus] id_reg2;
    wire id_write;
    wire[`RegAddressBus] id_write_address;

    wire[`AluOpBus] ex_aluop;
    wire[`AluSelBus] ex_alusel;
    wire[`RegBus] ex_reg1;
    wire[`RegBus] ex_reg2;
    wire ex_write;
    wire[`RegAddressBus] ex_write_address;

    wire ex_write_o;
    wire[`RegAddressBus] ex_write_address_o;
    wire[`RegBus] ex_write_data;

    wire mem_write;
    wire[`RegAddressBus] mem_write_address;
    wire[`RegBus] mem_write_data;

    wire mem_write_o;
    wire[`RegAddressBus] mem_write_address_o;
    wire[`RegBus] mem_write_data_o;

    wire wb_write;
    wire[`RegAddressBus] wb_write_address;
    wire[`RegBus] wb_write_data;

    wire id_read1;
    wire[`RegAddressBus] id_read1_address;
    wire[`RegBus] id_read1_data;
    wire id_read2;
    wire[`RegAddressBus] id_read2_address;
    wire[`RegBus] id_read2_data;

    pc_reg pc_reg0(
        .clock(clock), .reset(reset),
        .pc(pc), .ce(rom_ce)
    );

    assign rom_address = pc;

    if_id if_id0(
        .clock(clock), .reset(reset),
        .if_pc(pc), .if_instruction(rom_data),
        .id_pc(id_pc), .id_instruction(id_instruction)
    );

    id id0(
        .reset(reset),
        .pc(id_pc), .instruction(id_instruction),
        .read1(id_read1), .read1_address(id_read1_address), .read1_data(id_read1_data),
        .read2(id_read2), .read2_address(id_read2_address), .read2_data(id_read2_data),
        .aluop(id_aluop), .alusel(id_alusel), .reg1(id_reg1), .reg2(id_reg2),
        .write(id_write), .write_address(id_write_address)
    );

    id_ex id_ex0(
        .clock(clock), .reset(reset),
        .id_aluop(id_aluop), .id_alusel(id_alusel), .id_reg1(id_reg1), .id_reg2(id_reg2),
        .id_write(id_write), .id_write_address(id_write_address),
        .ex_aluop(ex_aluop), .ex_alusel(ex_alusel), .ex_reg1(ex_reg1), .ex_reg2(ex_reg2),
        .ex_write(ex_write), .ex_write_address(ex_write_address)
    );

    ex ex0(
        .reset(reset),
        .aluop(ex_aluop), .alusel(ex_alusel), .reg1(ex_reg1), .reg2(ex_reg2),
        .write(ex_write), .write_address(ex_write_address),
        .write_o(ex_write_o), .write_address_o(ex_write_address_o), .write_data(ex_write_data)
    );

    ex_mem ex_mem0(
        .clock(clock), .reset(reset),
        .ex_write(ex_write_o), .ex_write_address(ex_write_address_o), .ex_write_data(ex_write_data),
        .mem_write(mem_write), .mem_write_address(mem_write_address), .mem_write_data(mem_write_data)
    );

    mem mem0(
        .reset(reset),
        .write(mem_write), .write_address(mem_write_address), .write_data(mem_write_data),
        .write_o(mem_write_o), .write_address_o(mem_write_address_o), .write_data_o(mem_write_data_o)
    );

    mem_wb mem_wb0(
        .clock(clock), .reset(reset),
        .mem_write(mem_write_o), .mem_write_address(mem_write_address_o), .mem_write_data(mem_write_data_o),
        .wb_write(wb_write), .wb_write_address(wb_write_address), .wb_write_data(wb_write_data)
    );

    regfile regfile0(
        .clock(clock), .reset(reset),
        .write(wb_write), .write_address(wb_write_address), .write_data(wb_write_data),
        .read1(id_read1), .read1_address(id_read1_address), .read1_data(id_read1_data),
        .read2(id_read2), .read2_address(id_read2_address), .read2_data(id_read2_data)
    );

endmodule