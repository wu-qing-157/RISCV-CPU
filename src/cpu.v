`include "define.v"

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

    wire reset = rst_in || !rdy_in;
    assign dbgreg_dout = reset;

    wire ex_br, ex_br_inst, ex_br_error;
    wire [`MemAddrBus] ex_br_addr, ex_br_actual_addr;

    wire ctrl_stall_stall_if, ctrl_stall_stall_id, ctrl_stall_stall_ex, ctrl_stall_stall_mem;
    wire [`StallBus] ctrl_stall_stall;
    ctrl_stall ctrl_stall_(
        .reset(reset),
        .stall_if(ctrl_stall_stall_if), .stall_id(ctrl_stall_stall_id),
        .stall_ex(ctrl_stall_stall_ex), .stall_mem(ctrl_stall_stall_mem),
        .stall(ctrl_stall_stall)
    );

    wire br = ex_br && !ctrl_stall_stall[3];
    wire br_inst = ex_br_inst && !ctrl_stall_stall[3];
    wire br_error = ex_br_error;

    wire [`MemAddrBus] reg_pc_pc_i;
    wire [`MemAddrBus] reg_pc_pc_o;
    reg_pc reg_pc_(
        .clock(clk_in), .reset(reset), .stall0(ctrl_stall_stall[0]),
        .br(br_error), .br_addr(ex_br_actual_addr), .pc_i(reg_pc_pc_i), .pc_o(reg_pc_pc_o)
    );

    wire [`MemAddrBus] pipe_if_id_pc_i, pipe_if_id_pc_o;
    wire [`InstBus] pipe_if_id_inst_i, pipe_if_id_inst_o;
    wire pipe_if_id_prediction_i, pipe_if_id_prediction_o;
    pipe_if_id pipe_if_id_(
        .clock(clk_in), .reset(reset), .discard(br_error), .stall(ctrl_stall_stall[2:1]),
        .pc_i(pipe_if_id_pc_i), .inst_i(pipe_if_id_inst_i),
        .prediction_i(pipe_if_id_prediction_i),
        .pc_o(pipe_if_id_pc_o), .inst_o(pipe_if_id_inst_o),
        .prediction_o(pipe_if_id_prediction_o)
    );

    wire [`AluSelBus] pipe_id_ex_alusel_i, pipe_id_ex_alusel_o;
    wire [`AluOpBus] pipe_id_ex_aluop_i, pipe_id_ex_aluop_o;
    wire [`RegBus] pipe_id_ex_op1_i, pipe_id_ex_op1_o;
    wire [`RegBus] pipe_id_ex_op2_i, pipe_id_ex_op2_o;
    wire [`RegBus] pipe_id_ex_link_addr_i, pipe_id_ex_link_addr_o;
    wire pipe_id_ex_write_i, pipe_id_ex_write_o;
    wire [`RegAddrBus] pipe_id_ex_regw_addr_i, pipe_id_ex_regw_addr_o;
    wire [`RegBus] pipe_id_ex_mem_offset_i, pipe_id_ex_mem_offset_o;
    wire [`MemAddrBus] pipe_id_ex_br_addr_i, pipe_id_ex_br_addr_o;
    wire [`MemAddrBus] pipe_id_ex_br_offset_i, pipe_id_ex_br_offset_o;
    wire pipe_id_ex_prediction_i, pipe_id_ex_prediction_o;
    wire [`MemAddrBus] pipe_id_ex_pc_i, pipe_id_ex_pc_o;
    wire pipe_id_ex_no_prediction_i, pipe_id_ex_no_prediction_o;
    pipe_id_ex pipe_id_ex_(
        .clock(clk_in), .reset(reset), .discard(br_error), .stall(ctrl_stall_stall[3:2]),
        .alusel_i(pipe_id_ex_alusel_i), .aluop_i(pipe_id_ex_aluop_i),
        .op1_i(pipe_id_ex_op1_i), .op2_i(pipe_id_ex_op2_i), .link_addr_i(pipe_id_ex_link_addr_i),
        .write_i(pipe_id_ex_write_i), .regw_addr_i(pipe_id_ex_regw_addr_i),
        .mem_offset_i(pipe_id_ex_mem_offset_i),
        .br_addr_i(pipe_id_ex_br_addr_i), .br_offset_i(pipe_id_ex_br_offset_i),
        .prediction_i(pipe_id_ex_prediction_i), .pc_i(pipe_id_ex_pc_i),
        .no_prediction_i(pipe_id_ex_no_prediction_i),
        .alusel_o(pipe_id_ex_alusel_o), .aluop_o(pipe_id_ex_aluop_o),
        .op1_o(pipe_id_ex_op1_o), .op2_o(pipe_id_ex_op2_o), .link_addr_o(pipe_id_ex_link_addr_o),
        .write_o(pipe_id_ex_write_o), .regw_addr_o(pipe_id_ex_regw_addr_o),
        .mem_offset_o(pipe_id_ex_mem_offset_o),
        .br_addr_o(pipe_id_ex_br_addr_o), .br_offset_o(pipe_id_ex_br_offset_o),
        .prediction_o(pipe_id_ex_prediction_o), .pc_o(pipe_id_ex_pc_o),
        .no_prediction_o(pipe_id_ex_no_prediction_o)
    );

    wire pipe_ex_mem_write_i, pipe_ex_mem_write_o;
    wire [`RegAddrBus] pipe_ex_mem_regw_addr_i, pipe_ex_mem_regw_addr_o;
    wire [`RegBus] pipe_ex_mem_regw_data_i, pipe_ex_mem_regw_data_o;
    wire pipe_ex_mem_load_i, pipe_ex_mem_load_o;
    wire pipe_ex_mem_store_i, pipe_ex_mem_store_o;
    wire [`MemDataBus] pipe_ex_mem_mem_write_data_i, pipe_ex_mem_mem_write_data_o;
    wire [2:0] pipe_ex_mem_mem_length_i, pipe_ex_mem_mem_length_o;
    wire pipe_ex_mem_mem_signed_i, pipe_ex_mem_mem_signed_o;
    pipe_ex_mem pipe_ex_mem_(
        .clock(clk_in), .reset(reset), .stall(ctrl_stall_stall[4:3]),
        .write_i(pipe_ex_mem_write_i),
        .regw_addr_i(pipe_ex_mem_regw_addr_i), .regw_data_i(pipe_ex_mem_regw_data_i),
        .load_i(pipe_ex_mem_load_i), .store_i(pipe_ex_mem_store_i),
        .mem_write_data_i(pipe_ex_mem_mem_write_data_i),
        .mem_length_i(pipe_ex_mem_mem_length_i), .mem_signed_i(pipe_ex_mem_mem_signed_i),
        .write_o(pipe_ex_mem_write_o),
        .regw_addr_o(pipe_ex_mem_regw_addr_o), .regw_data_o(pipe_ex_mem_regw_data_o),
        .load_o(pipe_ex_mem_load_o), .store_o(pipe_ex_mem_store_o),
        .mem_write_data_o(pipe_ex_mem_mem_write_data_o),
        .mem_length_o(pipe_ex_mem_mem_length_o), .mem_signed_o(pipe_ex_mem_mem_signed_o)
    );

    wire pipe_mem_wb_write_i, pipe_mem_wb_write_o;
    wire [`RegAddrBus] pipe_mem_wb_regw_addr_i, pipe_mem_wb_regw_addr_o;
    wire [`RegBus] pipe_mem_wb_regw_data_i, pipe_mem_wb_regw_data_o;
    pipe_mem_wb pipe_mem_wb_(
        .clock(clk_in), .reset(reset), .stall(ctrl_stall_stall[5:4]),
        .write_i(pipe_mem_wb_write_i), .write_o(pipe_mem_wb_write_o),
        .regw_addr_i(pipe_mem_wb_regw_addr_i), .regw_data_i(pipe_mem_wb_regw_data_i),
        .regw_addr_o(pipe_mem_wb_regw_addr_o), .regw_data_o(pipe_mem_wb_regw_data_o)
    );

    buffer_branch buffer_branch_(
        .clock(clk_in), .reset(reset),
        .pc_i(pipe_if_id_pc_i), .pc_o(reg_pc_pc_i), .prediction(pipe_if_id_prediction_i),
        .update(ex_br_inst), .committed(ex_br),
        .current(pipe_id_ex_pc_o[`BTBAllBytes]), .target(ex_br_addr)
    );

    wire stage_if_ram_read, stage_if_ram_ready;
    wire [`MemAddrBus] stage_if_ram_addr;
    wire [`InstBus] stage_if_ram_data;
    stage_if stage_if_(
        .reset(reset), .stall_if(ctrl_stall_stall_if),
        .pc_i(reg_pc_pc_o), .pc_o(pipe_if_id_pc_i), .inst_o(pipe_if_id_inst_i),
        .ram_read(stage_if_ram_read), .ram_ready(stage_if_ram_ready),
        .ram_addr(stage_if_ram_addr), .ram_data(stage_if_ram_data)
    );

    wire cache_i_ram_read, cache_i_ram_ready, cache_i_ram_busy;
    wire [`MemAddrBus] cache_i_ram_addr;
    wire [`MemDataBus] cache_i_ram_data;
    cache_i cache_i_(
        .clock(clk_in), .reset(reset), .discard(br_error),
        .read(stage_if_ram_read), .addr(stage_if_ram_addr),
        .ready(stage_if_ram_ready), .data(stage_if_ram_data),
        .ram_busy(cache_i_ram_busy), .ram_ready(cache_i_ram_ready), .ram_data(cache_i_ram_data),
        .ram_read(cache_i_ram_read), .ram_addr(cache_i_ram_addr)
    );

    stage_ex stage_ex_(
        .reset(reset), .stall_ex(ctrl_stall_stall_ex),
        .alusel(pipe_id_ex_alusel_o), .aluop(pipe_id_ex_aluop_o),
        .op1(pipe_id_ex_op1_o), .op2(pipe_id_ex_op2_o), .link_addr(pipe_id_ex_link_addr_o),
        .write_i(pipe_id_ex_write_o), .regw_addr_i(pipe_id_ex_regw_addr_o),
        .mem_offset(pipe_id_ex_mem_offset_o),
        .br_addr_i(pipe_id_ex_br_addr_o), .br_offset(pipe_id_ex_br_offset_o),
        .write_o(pipe_ex_mem_write_i),
        .regw_addr_o(pipe_ex_mem_regw_addr_i), .regw_data(pipe_ex_mem_regw_data_i),
        .load(pipe_ex_mem_load_i), .store(pipe_ex_mem_store_i),
        .mem_write_data(pipe_ex_mem_mem_write_data_i),
        .mem_length(pipe_ex_mem_mem_length_i), .mem_signed(pipe_ex_mem_mem_signed_i),
        .no_prediction(pipe_id_ex_no_prediction_o),
        .prediction(pipe_id_ex_prediction_o), .pc(pipe_id_ex_pc_o),
        .br_inst(ex_br_inst), .br_addr_o(ex_br_addr), .br(ex_br),
        .br_error(ex_br_error), .br_actual_addr(ex_br_actual_addr)
    );

    wire stage_mem_ram_ready, stage_mem_ram_read, stage_mem_ram_write, stage_mem_ram_signed;
    wire [`MemAddrBus] stage_mem_ram_addr;
    wire [`MemDataBus] stage_mem_ram_data_i, stage_mem_ram_data_o;
    wire [2:0] stage_mem_ram_length;
    stage_mem stage_mem_(
        .reset(reset), .stall_mem(ctrl_stall_stall_mem),
        .load(pipe_ex_mem_load_o), .store(pipe_ex_mem_store_o),
        .addr(pipe_ex_mem_regw_data_o), .data(pipe_ex_mem_mem_write_data_o),
        .length(pipe_ex_mem_mem_length_o), .signed_(pipe_ex_mem_mem_signed_o),
        .write_i(pipe_ex_mem_write_o),
        .regw_addr_i(pipe_ex_mem_regw_addr_o), .regw_data_i(pipe_ex_mem_regw_data_o),
        .write_o(pipe_mem_wb_write_i),
        .regw_addr_o(pipe_mem_wb_regw_addr_i), .regw_data_o(pipe_mem_wb_regw_data_i),
        .ram_ready(stage_mem_ram_ready), .ram_addr(stage_mem_ram_addr),
        .ram_data_i(stage_mem_ram_data_i), .ram_data_o(stage_mem_ram_data_o),
        .ram_length(stage_mem_ram_length), .ram_signed(stage_mem_ram_signed),
        .ram_read(stage_mem_ram_read), .ram_write(stage_mem_ram_write)
    );

    wire cache_d_ram_busy, cache_d_ram_ready, cache_d_ram_read, cache_d_ram_signed;
    wire [2:0] cache_d_ram_length;
    wire [`MemAddrBus] cache_d_ram_addr;
    wire [`MemDataBus] cache_d_ram_data;
    wire cache_d_buffer_busy, cache_d_buffer_write;
    wire [2:0] cache_d_buffer_length;
    wire [`MemAddrBus] cache_d_buffer_addr;
    wire [`MemDataBus] cache_d_buffer_data;
    cache_d cache_d_(
        .clock(clk_in), .reset(reset),
        .read(stage_mem_ram_read), .write(stage_mem_ram_write), .ready(stage_mem_ram_ready),
        .length(stage_mem_ram_length), .signed_(stage_mem_ram_signed),
        .addr(stage_mem_ram_addr),
        .data_i(stage_mem_ram_data_o), .data_o(stage_mem_ram_data_i),
        .ram_busy(cache_d_ram_busy), .ram_ready(cache_d_ram_ready), .ram_read(cache_d_ram_read),
        .ram_length(cache_d_ram_length), .ram_signed(cache_d_ram_signed),
        .ram_addr(cache_d_ram_addr), .ram_data(cache_d_ram_data),
        .buffer_busy(cache_d_buffer_busy), .buffer_write(cache_d_buffer_write),
        .buffer_length(cache_d_buffer_length), .buffer_addr(cache_d_buffer_addr),
        .buffer_data(cache_d_buffer_data)
    );

    wire buffer_ram_busy, buffer_ram_write, buffer_ram_success;
    wire [`MemAddrBus] buffer_ram_addr;
    wire [`ByteBus] buffer_ram_data;
    buffer_write buffer_(
        .clock(clk_in), .reset(reset),
        .write(cache_d_buffer_write), .busy(cache_d_buffer_busy),
        .length(cache_d_buffer_length), .addr(cache_d_buffer_addr), .data(cache_d_buffer_data),
        .ram_busy(buffer_ram_busy), .ram_write(buffer_ram_write), .ram_seccess(buffer_ram_success),
        .ram_addr(buffer_ram_addr), .ram_data(buffer_ram_data)
    );

    ctrl_mem ctrl_mem_(
        .clock(clk_in), .reset(reset), .if_discard(br_error),
        .if_read(cache_i_ram_read), .if_addr(cache_i_ram_addr),
        .if_busy(cache_i_ram_busy), .if_ready(cache_i_ram_ready), .if_data(cache_i_ram_data),
        .mem_read(cache_d_ram_read), .mem_r_addr(cache_d_ram_addr),
        .mem_r_length(cache_d_ram_length), .mem_r_signed(cache_d_ram_signed),
        .mem_r_busy(cache_d_ram_busy), .mem_r_ready(cache_d_ram_ready),
        .mem_r_data(cache_d_ram_data),
        .mem_write(buffer_ram_write), .mem_w_addr(buffer_ram_addr),
        .mem_w_data(buffer_ram_data), .mem_w_busy(buffer_ram_busy),
        .mem_w_success(buffer_ram_success),
        .ram_rw(mem_wr), .ram_addr(mem_a),
        .ram_w_data(mem_dout), .ram_r_data(mem_din)
    );

    wire stage_id_read1, stage_id_read2;
    wire [`RegAddrBus] stage_id_reg1_addr, stage_id_reg2_addr;
    wire [`RegBus] stage_id_reg1_data, stage_id_reg2_data;
    stage_id stage_id_(
        .reset(reset), .stall_id(ctrl_stall_stall_id),
        .pc_i(pipe_if_id_pc_o), .inst(pipe_if_id_inst_o),
        .alusel(pipe_id_ex_alusel_i), .aluop(pipe_id_ex_aluop_i),
        .op1(pipe_id_ex_op1_i), .op2(pipe_id_ex_op2_i), .link_addr(pipe_id_ex_link_addr_i),
        .write(pipe_id_ex_write_i), .regw_addr(pipe_id_ex_regw_addr_i),
        .mem_offset(pipe_id_ex_mem_offset_i),
        .br_addr(pipe_id_ex_br_addr_i), .br_offset(pipe_id_ex_br_offset_i),
        .ex_load(stage_ex_.load), .ex_write(stage_ex_.write_i),
        .ex_regw_addr(stage_ex_.regw_addr_i), .ex_regw_data(stage_ex_.regw_data),
        .mem_write(stage_mem_.write_i),
        .mem_regw_addr(stage_mem_.regw_addr_i), .mem_regw_data(stage_mem_.regw_data_o),
        .read1(stage_id_read1), .reg1_addr(stage_id_reg1_addr), .reg1_data(stage_id_reg1_data),
        .read2(stage_id_read2), .reg2_addr(stage_id_reg2_addr), .reg2_data(stage_id_reg2_data),
        .prediction_i(pipe_if_id_prediction_o), .prediction_o(pipe_id_ex_prediction_i),
        .pc_o(pipe_id_ex_pc_i), .no_prediction(pipe_id_ex_no_prediction_i)
    );

    reg_file reg_file_(
        .clock(clk_in), .reset(reset),
        .write(pipe_mem_wb_write_o),
        .regw_addr(pipe_mem_wb_regw_addr_o), .regw_data(pipe_mem_wb_regw_data_o),
        .read1(stage_id_read1), .reg1_addr(stage_id_reg1_addr), .reg1_data(stage_id_reg1_data),
        .read2(stage_id_read2), .reg2_addr(stage_id_reg2_addr), .reg2_data(stage_id_reg2_data)
    );

endmodule
