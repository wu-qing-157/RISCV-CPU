`include "define.v"

module id(
    input wire reset,
    
    input wire[`InstructionAddressBus] pc,
    input wire[`InstructionBus] instruction,

    output reg read1,
    output reg[`RegAddressBus] read1_address,
    input wire[`RegBus] read1_data,
    output reg read2,
    output reg[`RegAddressBus] read2_address,
    input wire[`RegBus] read2_data,

    output reg[`AluOpBus] aluop,
    output reg[`AluSelBus] alusel,
    output reg[`RegBus] reg1,
    output reg[`RegBus] reg2,
    output reg write,
    output reg[`RegAddressBus] write_address
);

    wire[5:0] op1 = instruction[31:26];
    wire[4:0] op2 = instruction[10:6];
    wire[5:0] op3 = instruction[5:0];
    wire[4:0] op4 = instruction[20:16];

    reg[`RegBus] imm;

    reg instruction_valid;

    always@(*) begin
        if (reset == 1) begin
            aluop <= 0;
            alusel <= 0;
            write <= 0;
            write_address <= 0;
            instruction_valid <= 1;
            read1 <= 0;
            read2 <= 0;
            read1_address <= 0;
            read2_address <= 0;
            imm <= 0;
        end else begin
            read1_address <= instruction[25:21];
            read2_address <= instruction[20:16];
            case (instruction[31:26])
                `EXE_ORI: begin
                    aluop <= `EXEOP_OR;
                    alusel <= `EXERES_LOGIC;
                    read1 <= 1;
                    read2 <= 0;
                    imm <= {16'h0, instruction[15:0]};
                    write <= 1;
                    write_address <= instruction[20:16];
                    instruction_valid <= 1;
                end
                default: begin
                    aluop <= 0;
                    alusel <= 0;
                    read1 <= 0;
                    read2 <= 0;
                    imm <= 0;
                    write <= 0;
                    write_address <= 0;
                    instruction_valid <= 0;
                end
            endcase
        end
    end

    always@(*) begin
        if (reset == 1) begin
            reg1 <= 0;
        end else if (read1 == 1) begin
            reg1 <= read1_data;
        end else begin
            reg1 <= imm;
        end
    end

    always@(*) begin
        if (reset == 1) begin
            reg2 <= 0;
        end else if (read2 == 1) begin
            reg2 <= read2_data;
        end else begin
            reg2 <= imm;
        end
    end

endmodule