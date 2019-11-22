`include "define.v"
`include "stage_if.v"
`include "stage_id.v"
`include "stage_ex.v"
`include "stage_mem.v"
`include "reg_pc.v"
`include "reg_file.v"
`include "pipe_if_id.v"
`include "pipe_id_ex.v"
`include "pipe_ex_mem.v"
`include "pipe_mem_wb.v"
`include "fake_mem_if.v"

// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
    input wire clk_in,    // system clock signal
    input wire rst_in, // reset signal
    input wire rdy_in, // TODO ready signal, pause cpu when low
    input wire [7:0] mem_din, // data input bus
    output wire [7:0] mem_dout, // data output bus
    output wire [31:0] mem_a, // address bus (only 17:0 is used)
    output wire mem_wr, // write/read signal (1 for write)
    output wire [31:0] dbgreg_dout // cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read takes 2 cycles(wait till next cycle), write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

    wire [`MemAddrBus] reg_if_pc;
    wire [`MemAddrBus] if_pc_o;
    wire [`InstBus] fake_if_inst;
    wire [`InstBus] if_inst_o;

    reg_pc reg_pc_(
        .clock(clk_in), .reset(rst_in),
        .pc_o(reg_if_pc)
    );

    fake_mem_if fake_mem_id_(
        .reset(rst_in), .pc(if_pc_o), .inst(fake_if_inst)
    );

    stage_if stage_if_(
        .reset(rst_in), .pc_i(reg_if_pc),
        .pc_o(if_pc_o), .mem_data_i(fake_if_inst), .inst_o(if_inst_o)
    );

    wire [`RegBus] id_pc;
    wire [`InstBus] id_inst;
    wire id_read1;
    wire [`RegAddrBus] id_reg1_addr;
    wire [`RegBus] id_reg1_data;
    wire id_read2;
    wire [`RegAddrBus] id_reg2_addr;
    wire [`RegBus] id_reg2_data;
    wire [`AluSelBus] id_alusel;
    wire [`AluOpBus] id_aluop;
    wire [`RegBus] id_op1;
    wire [`RegBus] id_op2;
    wire id_write;
    wire [`RegAddrBus] id_regw_addr;

    pipe_if_id pipe_if_id_(
        .clock(clk_in), .reset(rst_in),
        .pc_i(if_pc_o), .inst_i(if_inst_o),
        .pc_o(id_pc), .inst_o(id_inst)
    );

    stage_id stage_id_(
        .reset(rst_in),
        .pc(id_pc), .inst(id_inst),
        .read1(id_read1), .reg1_addr(id_reg1_addr), .reg1_data(id_reg1_data),
        .read2(id_read2), .reg2_addr(id_reg2_addr), .reg2_data(id_reg2_data),
        .alusel(id_alusel), .aluop(id_aluop), .op1(id_op1), .op2(id_op2),
        .write(id_write), .regw_addr(id_regw_addr)
    );

    wire [`AluSelBus] ex_alusel;
    wire [`AluOpBus] ex_aluop;
    wire [`RegBus] ex_op1;
    wire [`RegBus] ex_op2;
    wire ex_write_i;
    wire [`RegAddrBus] ex_regw_addr_i;
    wire ex_write_o;
    wire [`RegAddrBus] ex_regw_addr_o;
    wire [`RegBus] ex_regw_data;

    pipe_id_ex pipe_id_ex_(
        .clock(clk_in), .reset(rst_in),
        .alusel_i(id_alusel), .aluop_i(id_aluop), .op1_i(id_op1), .op2_i(id_op2),
        .write_i(id_write), .regw_addr_i(id_regw_addr),
        .alusel_o(ex_alusel), .aluop_o(ex_aluop), .op1_o(ex_op1), .op2_o(ex_op2),
        .write_o(ex_write_i), .regw_addr_o(ex_regw_addr_i)
    );

    stage_ex stage_ex_(
        .reset(rst_in),
        .alusel(ex_alusel), .aluop(ex_aluop), .op1(ex_op1), .op2(ex_op2),
        .write_i(ex_write_i), .regw_addr_i(ex_regw_addr_i),
        .write_o(ex_write_o), .regw_addr_o(ex_regw_addr_o), .regw_data(ex_regw_data)
    );

    wire mem_write_i;
    wire [`RegAddrBus] mem_regw_addr_i;
    wire [`RegBus] mem_regw_data_i;
    wire mem_write_o;
    wire [`RegAddrBus] mem_regw_addr_o;
    wire [`RegBus] mem_regw_data_o;

    pipe_ex_mem pipe_ex_mem_(
        .clock(clk_in), .reset(rst_in),
        .write_i(ex_write_o), .regw_addr_i(ex_regw_addr_o), .regw_data_i(ex_regw_data),
        .write_o(mem_write_i), .regw_addr_o(mem_regw_addr_i), .regw_data_o(mem_regw_data_i)
    );

    stage_mem stage_mem_(
        .reset(rst_in),
        .write_i(mem_write_i), .regw_addr_i(mem_regw_addr_i), .regw_data_i(mem_regw_data_i),
        .write_o(mem_write_o), .regw_addr_o(mem_regw_addr_o), .regw_data_o(mem_regw_data_o)
    );

    wire wb_write;
    wire [`RegAddrBus] wb_regw_addr;
    wire [`RegBus] wb_regw_data;

    pipe_mem_wb pipe_mem_wb_(
        .clock(clk_in), .reset(rst_in),
        .write_i(mem_write_o), .regw_addr_i(mem_regw_addr_o), .regw_data_i(mem_regw_data_o),
        .write_o(wb_write), .regw_addr_o(wb_regw_addr), .regw_data_o(wb_regw_data)
    );

    reg_file reg_file_(
        .clock(clk_in), .reset(rst_in),
        .write(wb_write), .regw_addr(wb_regw_addr), .regw_data(wb_regw_data),
        .read1(id_read1), .reg1_addr(id_reg1_addr), .reg1_data(id_reg1_data),
        .read2(id_read2), .reg2_addr(id_reg2_addr), .reg2_data(id_reg2_data)
    );

endmodule
