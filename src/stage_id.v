`include "define.v"

module stage_id(
    input wire reset,

    output reg stall_id,
    input wire [`StallBus] stall,

    input wire [`MemAddrBus] pc,
    input wire [`InstBus] inst,

    output reg read1,
    output reg [`RegAddrBus] reg1_addr,
    input wire [`RegBus] reg1_data,
    output reg read2,
    output reg [`RegAddrBus] reg2_addr,
    input wire [`RegBus] reg2_data,

    output reg [`AluSelBus] alusel,
    output reg [`AluOpBus] aluop,
    output reg [`RegBus] op1,
    output reg [`RegBus] op2,
    output reg [`RegBus] link_addr,
    output reg write,
    output reg [`RegAddrBus] regw_addr,
    output reg [`RegBus] mem_offset,

    output reg br,
    output reg [`MemAddrBus] br_addr,

    input wire ex_load,
    input wire ex_write,
    input wire [`RegAddrBus] ex_regw_addr,
    input wire [`RegBus] ex_regw_data,

    input wire mem_write,
    input wire [`RegAddrBus] mem_regw_addr,
    input wire [`RegBus] mem_regw_data
);

    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];
    wire [31:0] I_imm = {{20{inst[31]}}, inst[31:20]};
    wire [31:0] S_imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
    wire [31:0] B_imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
    wire [31:0] U_imm = {inst[31:12], 12'b0};
    wire [31:0] J_imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};

    wire [`RegAddrBus] rd = inst[11:7];
    wire [`RegAddrBus] rs = inst[19:15];
    wire [`RegAddrBus] rt = inst[24:20];

    reg [`RegBus] imm1, imm2;

    initial begin
        stall_id <= 0;
    end

    always @(*) begin
        alusel = 3'b000; aluop = 0;
        read1 = 0; reg1_addr = 0; imm1 = 0;
        read2 = 0; reg2_addr = 0; imm2 = 0;
        write = 0; regw_addr = 0;
        br = 0; br_addr = 0; link_addr = 0;
        if (!reset) begin
            case (opcode)
                7'b0110111: begin
                    alusel = 3'b100; aluop = 0;
                    imm1 = U_imm;
                    imm2 = 0;
                    write = 1; regw_addr = rd;
                end // LUI
                7'b0010111: begin
                    alusel = 3'b100; aluop = 0;
                    imm1 = U_imm;
                    imm2 = pc;
                    write = 1; regw_addr = rd;
                end // AUIPC
                7'b1101111: begin
                    alusel = 3'b110;
                    write = 1; regw_addr = rd;
                    br = 1; br_addr = pc+J_imm; link_addr = pc+4;
                end // JAL
                7'b1100111: begin
                    alusel = 3'b110;
                    write = 1; regw_addr = rd;
                    br = 1; br_addr = reg1_data+I_imm; link_addr = pc+4;
                end // JALR
                7'b1100011: begin
                    case (funct3)
                        3'b000: begin
                            alusel = 3'b110;
                            read1 = 1; reg1_addr = rs;
                            read2 = 1; reg2_addr = rt;
                            if (reg1_data == reg2_data) begin
                                br = 1; br_addr = pc+B_imm;
                            end
                        end // BEQ
                        3'b001: begin
                            alusel = 3'b110;
                            read1 = 1; reg1_addr = rs;
                            read2 = 1; reg2_addr = rt;
                            if (reg1_data != reg2_data) begin
                                br = 1; br_addr = pc+B_imm;
                            end
                        end // BNE
                        3'b100: begin
                            alusel = 3'b110;
                            read1 = 1; reg1_addr = rs;
                            read2 = 1; reg2_addr = rt;
                            if ($signed(reg1_data) < $signed(reg2_data)) begin
                                br = 1; br_addr = pc+B_imm;
                            end
                        end // BLT
                        3'b101: begin
                            alusel = 3'b110;
                            read1 = 1; reg1_addr = rs;
                            read2 = 1; reg2_addr = rt;
                            if (reg1_data < reg2_data) begin
                                br = 1; br_addr = pc+B_imm;
                            end
                        end // BLTU
                        3'b110: begin
                            alusel = 3'b110;
                            read1 = 1; reg1_addr = rs;
                            read2 = 1; reg2_addr = rt;
                            if ($signed(reg1_data) >= $signed(reg2_data)) begin
                                br = 1; br_addr = pc+B_imm;
                            end
                        end // BGE
                        3'b111: begin
                            alusel = 3'b110;
                            read1 = 1; reg1_addr = rs;
                            read2 = 1; reg2_addr = rt;
                            if (reg1_data >= reg2_data) begin
                                br = 1; br_addr = pc+B_imm;
                            end
                        end // BGEU
                    endcase
                end // BRANCH
                7'b0000011: begin
                    alusel = 3'b111;
                    read1 = 1; reg1_addr = rs;
                    write = 1; regw_addr = rd;
                    mem_offset = I_imm;
                    case (funct3)
                        3'b000: aluop = 0; // LB
                        3'b001: aluop = 1; // LH
                        3'b010: aluop = 2; // LW
                        3'b100: aluop = 3; // LBU
                        3'b101: aluop = 4; // LHU
                    endcase
                end // LOAD
                7'b0100011: begin
                    alusel = 3'b111;
                    read1 = 1; reg1_addr = rs;
                    read2 = 1; reg2_addr = rt;
                    mem_offset = S_imm;
                    case (funct3)
                        3'b000: aluop = 5; // SB
                        3'b001: aluop = 6; // SH
                        3'b010: aluop = 7; // SW
                    endcase
                end // STORE
                7'b0010011: begin
                    case (funct3)
                        3'b000: begin
                            alusel = 3'b100; aluop = 0;
                            read1 = 1; reg1_addr = rs;
                            imm2 = I_imm;
                            write = 1; regw_addr = rd;
                        end // ADDI
                        3'b010: begin
                            alusel = 3'b100; aluop = 2;
                            read1 = 1; reg1_addr = rs;
                            imm2 = I_imm;
                            write = 1; regw_addr = rd;
                        end // SLTI
                        3'b011: begin
                            alusel = 3'b100; aluop = 3;
                            read1 = 1; reg1_addr = rs;
                            imm2 = I_imm;
                            write = 1; regw_addr = rd;
                        end // SLTIU
                        3'b100: begin
                            alusel = 3'b001; aluop = 2;
                            read1 = 1; reg1_addr = rs;
                            imm2 = I_imm;
                            write = 1; regw_addr = rd;
                        end // XORI
                        3'b110: begin
                            alusel = 3'b001; aluop = 0;
                            read1 = 1; reg1_addr = rs;
                            imm2 = I_imm;
                            write = 1; regw_addr = rd;
                        end // ORI
                        3'b111: begin
                            alusel = 3'b001; aluop = 1;
                            read1 = 1; reg1_addr = rs;
                            imm2 = I_imm;
                            write = 1; regw_addr = rd;
                        end // ANDI
                        3'b001: begin
                            alusel = 3'b010; aluop = 0;
                            read1 = 1; reg1_addr = rs;
                            imm2 = {20'b0, rt};
                            write = 1; regw_addr = rd;
                        end // SLLI
                        3'b101: begin
                            case (funct7)
                                7'b0000000: begin
                                    alusel = 3'b010; aluop = 1;
                                    read1 = 1; reg1_addr = rs;
                                    imm2 = {20'b0, rt};
                                    write = 1; regw_addr = rd;
                                end // SRLI
                                7'b0100000: begin
                                    alusel = 3'b010; aluop = 2;
                                    read1 = 1; reg1_addr = rs;
                                    imm2 = {20'b0, rt};
                                    write = 1; regw_addr = rd;
                                end // SRAI
                            endcase
                        end // SRLI & SRAI
                    endcase
                end // OP_IMM
                7'b0110011: begin
                    case (funct3)
                        3'b000: begin
                            case (funct7)
                                7'b0000000: begin
                                    alusel = 3'b100; aluop = 0;
                                    read1 = 1; reg1_addr = rs;
                                    read2 = 1; reg2_addr = rt;
                                    write = 1; regw_addr = rd;
                                end // ADD
                                7'b0100000: begin
                                    alusel = 3'b100; aluop = 1;
                                    read1 = 1; reg1_addr = rs;
                                    read2 = 1; reg2_addr = rt;
                                    write = 1; regw_addr = rd;
                                end // SUB
                            endcase
                        end // ADD & SUB
                        3'b001: begin
                            alusel = 3'b010; aluop = 0;
                            read1 = 1; reg1_addr = rs;
                            read2 = 1; reg2_addr = rt;
                            write = 1; regw_addr = rd;
                        end // SLL
                        3'b010: begin
                            alusel = 3'b100; aluop = 2;
                            read1 = 1; reg1_addr = rs;
                            read2 = 1; reg2_addr = rt;
                            write = 1; regw_addr = rd;
                        end // SLT
                        3'b011: begin
                            alusel = 3'b100; aluop = 3;
                            read1 = 1; reg1_addr = rs;
                            read2 = 1; reg2_addr = rt;
                            write = 1; regw_addr = rd;
                        end // SLTU
                        3'b100: begin
                            alusel = 3'b001; aluop = 2;
                            read1 = 1; reg1_addr = rs;
                            read2 = 1; reg2_addr = rt;
                            write = 1; regw_addr = rd;
                        end // XOR
                        3'b101: begin
                            case (funct7)
                                7'b0000000: begin
                                    alusel = 3'b010; aluop = 1;
                                    read1 = 1; reg1_addr = rs;
                                    read2 = 1; reg2_addr = rt;
                                    write = 1; regw_addr = rd;
                                end // SRL
                                7'b0100000: begin
                                    alusel = 3'b010; aluop = 1;
                                    read1 = 1; reg1_addr = rs;
                                    read2 = 1; reg2_addr = rt;
                                    write = 1; regw_addr = rd;
                                end // SRA
                            endcase
                        end // SRL & SRA
                        3'b110: begin
                            alusel = 3'b001; aluop = 0;
                            read1 = 1; reg1_addr = rs;
                            read2 = 1; reg2_addr = rt;
                            write = 1; regw_addr = rd;
                        end // OR
                        3'b111: begin
                            alusel = 3'b001; aluop = 1;
                            read1 = 1; reg1_addr = rs;
                            read2 = 1; reg2_addr = rt;
                            write = 1; regw_addr = rd;
                        end // AND
                    endcase
                end // OP_OP
            endcase
        end
    end

    always @(*) begin
        if (reset) begin
            op1 = 0;
        end else if (read1 == 0) begin
            op1 = imm1;
        end else if (ex_load && ex_regw_addr == reg1_addr) begin
            stall_id = 1;
        end else if (ex_write && ex_regw_addr == reg1_addr) begin
            op1 = ex_regw_data;
        end else if (mem_write && mem_regw_addr == reg1_addr) begin
            op1 = mem_regw_data;
        end else begin
            op1 = reg1_data;
        end
    end

    always @(*) begin
        if (reset) begin
            op2 = 0;
        end else if (read2 == 0) begin
            op2 = imm2;
        end else if (ex_load && ex_regw_addr == reg2_addr) begin
            stall_id = 1;
        end else if (ex_write && ex_regw_addr == reg2_addr) begin
            if (stall[3]) begin
                stall_id = 1;
            end else begin
                op2 = ex_regw_data;
            end
        end else if (mem_write && mem_regw_addr == reg2_addr) begin
            if (stall[4]) begin
                stall_id = 1;
            end else begin
                op2 = mem_regw_data;
            end
        end else begin
            op2 = reg2_data;
        end
    end

endmodule
