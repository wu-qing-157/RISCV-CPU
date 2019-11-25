`include "define.v"
`include "ctrl_stall.v"
`include "ctrl_mem.v"
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

    wire [5:0] stall;
    wire stall_if, stall_id, stall_ex, stall_mem;

    ctrl_stall ctrl_stall_(
        .stall(stall),
        .stall_if(stall_if), .stall_id(stage_id), .stall_ex(stall_ex), .stall_mem(stall_mem)
    );

    wire ram_busy;
    wire ram_if_read;
    wire [`MemAddrBus] ram_if_addr_i;
    wire ram_if_ready;
    wire [`MemAddrBus] ram_if_addr_o;
    wire [`MemDataBus] ram_if_data_o;
    wire ram_mem_read, ram_mem_write;
    wire [`MemAddrBus] ram_mem_addr;
    wire [`MemDataBus] ram_mem_data_i;
    wire [2:0] ram_mem_length;
    wire ram_mem_signed;
    wire ram_mem_ready;
    wire [`MemDataBus] ram_mem_data_o;

    ctrl_mem ctrl_mem_(
        .clock(clk_in), .reset(rst_in),
        .ram_rw(mem_wr), .ram_addr(mem_a), .ram_w_data(mem_dout), .ram_r_data(mem_din),
        .busy(ram_busy),
        .if_read(ram_if_read), .if_addr_i(ram_if_addr_i),
        .if_ready(ram_if_ready), .if_addr_o(ram_if_addr_o), .if_data_o(ram_if_data_o),
        .mem_read(ram_mem_read), .mem_write(ram_mem_write), .mem_addr(ram_mem_addr),
        .mem_data_i(ram_mem_data_i), .mem_length(ram_mem_length), .mem_signed(ram_mem_signed),
        .mem_ready(ram_mem_ready), .mem_data_o(ram_mem_data_o)
    );

    wire [`MemAddrBus] reg_if_pc;
    wire [`MemAddrBus] if_pc_o;
    wire [`InstBus] if_inst_o;

    wire br;
    wire [`MemAddrBus] br_addr;

    reg_pc reg_pc_(
        .clock(clk_in), .reset(rst_in), .stall(stall),
        .br(br), .br_addr(br_addr),
        .pc_o(reg_if_pc)
    );

    stage_if stage_if_(
        .reset(rst_in), .stall_if(stall_if),
        .pc_i(reg_if_pc), .pc_o(if_pc_o), .inst_o(if_inst_o),
        .br(br), .br_addr(br_addr),
        .ram_busy(ram_busy), .ram_ready(ram_if_ready),
        .ram_addr_i(ram_if_addr_o), .ram_data_i(ram_if_data_o),
        .ram_read(ram_if_read), .ram_addr_o(ram_if_addr_i)
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
    wire [`RegBus] id_link_addr;
    wire id_write;
    wire [`RegAddrBus] id_regw_addr;
    wire [`RegBus] id_mem_offset;

    pipe_if_id pipe_if_id_(
        .clock(clk_in), .reset(rst_in), .stall(stall),
        .pc_i(if_pc_o), .inst_i(if_inst_o),
        .pc_o(id_pc), .inst_o(id_inst)
    );

    wire [`AluSelBus] ex_alusel;
    wire [`AluOpBus] ex_aluop;
    wire [`RegBus] ex_op1;
    wire [`RegBus] ex_op2;
    wire [`RegBus] ex_link_addr;
    wire ex_write_i;
    wire [`RegAddrBus] ex_regw_addr_i;
    wire [`RegBus] ex_mem_offset;
    wire ex_load, ex_store;
    wire ex_write_o;
    wire [`RegAddrBus] ex_regw_addr_o;
    wire [`RegBus] ex_regw_data;
    wire [`MemDataBus] ex_mem_write_data;
    wire [2:0] ex_mem_length;
    wire ex_mem_signed;

    pipe_id_ex pipe_id_ex_(
        .clock(clk_in), .reset(rst_in), .stall(stall),
        .alusel_i(id_alusel), .aluop_i(id_aluop),
        .op1_i(id_op1), .op2_i(id_op2), .link_addr_i(id_link_addr),
        .write_i(id_write), .regw_addr_i(id_regw_addr), .mem_offset_i(id_mem_offset),
        .alusel_o(ex_alusel), .aluop_o(ex_aluop),
        .op1_o(ex_op1), .op2_o(ex_op2), .link_addr_o(ex_link_addr),
        .write_o(ex_write_i), .regw_addr_o(ex_regw_addr_i), .mem_offset_o(ex_mem_offset)
    );

    stage_ex stage_ex_(
        .reset(rst_in), .stall_ex(stall_ex),
        .alusel(ex_alusel), .aluop(ex_aluop),
        .op1(ex_op1), .op2(ex_op2), .link_addr(ex_link_addr),
        .write_i(ex_write_i), .regw_addr_i(ex_regw_addr_i), .mem_offset(ex_mem_offset),
        .load(ex_load), .store(ex_store),
        .write_o(ex_write_o), .regw_addr_o(ex_regw_addr_o), .regw_data(ex_regw_data),
        .mem_write_data(ex_mem_write_data), .mem_length(ex_mem_length), .mem_signed(ex_mem_signed)
    );

    wire mem_write_i;
    wire [`RegAddrBus] mem_regw_addr_i;
    wire [`RegBus] mem_regw_data_i;
    wire mem_load, mem_store;
    wire [`MemDataBus] mem_data;
    wire [2:0] mem_length;
    wire mem_signed;
    wire mem_write_o;
    wire [`RegAddrBus] mem_regw_addr_o;
    wire [`RegBus] mem_regw_data_o;

    pipe_ex_mem pipe_ex_mem_(
        .clock(clk_in), .reset(rst_in), .stall(stall),
        .write_i(ex_write_o), .regw_addr_i(ex_regw_addr_o), .regw_data_i(ex_regw_data),
        .load_i(ex_load), .store_i(ex_store),
        .mem_write_data_i(ex_mem_write_data), .mem_length_i(ex_mem_length),
        .mem_signed_i(ex_mem_signed),
        .write_o(mem_write_i), .regw_addr_o(mem_regw_addr_i), .regw_data_o(mem_regw_data_i),
        .load_o(mem_load), .store_o(mem_store),
        .mem_write_data_o(mem_data), .mem_length_o(mem_length), .mem_signed_o(mem_signed)
    );

    stage_mem stage_mem_(
        .reset(rst_in), .stall_mem(stall_mem),
        .write_i(mem_write_i), .regw_addr_i(mem_regw_addr_i), .regw_data_i(mem_regw_data_i),
        .addr(mem_regw_data_i), .load(mem_load), .store(mem_store), .data(mem_data),
        .length(mem_length), .signed_(mem_signed),
        .write_o(mem_write_o), .regw_addr_o(mem_regw_addr_o), .regw_data_o(mem_regw_data_o),
        .ram_busy(ram_busy), .ram_ready(ram_mem_ready), .ram_data_i(ram_mem_data_o),
        .ram_read(ram_mem_read), .ram_write(ram_mem_write), .ram_addr(ram_mem_addr),
        .ram_data_o(ram_mem_data_i), .ram_length(ram_mem_length), .ram_signed(ram_mem_signed)
    );

    stage_id stage_id_(
        .reset(rst_in), .stall_id(stage_id),
        .pc(id_pc), .inst(id_inst),
        .read1(id_read1), .reg1_addr(id_reg1_addr), .reg1_data(id_reg1_data),
        .read2(id_read2), .reg2_addr(id_reg2_addr), .reg2_data(id_reg2_data),
        .br(br), .br_addr(br_addr),
        .alusel(id_alusel), .aluop(id_aluop),
        .op1(id_op1), .op2(id_op2), .link_addr(id_link_addr),
        .write(id_write), .regw_addr(id_regw_addr), .mem_offset(id_mem_offset),
        .ex_load(ex_load),
        .ex_write(ex_write_o), .ex_regw_addr(ex_regw_addr_o), .ex_regw_data(ex_regw_data),
        .mem_write(mem_write_o), .mem_regw_addr(mem_regw_addr_o), .mem_regw_data(mem_regw_data_o)
    );

    wire wb_write;
    wire [`RegAddrBus] wb_regw_addr;
    wire [`RegBus] wb_regw_data;

    pipe_mem_wb pipe_mem_wb_(
        .clock(clk_in), .reset(rst_in), .stall(stall),
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
