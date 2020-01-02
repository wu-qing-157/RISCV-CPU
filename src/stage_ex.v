`include "define.v"

module stage_ex(
    input wire reset,

    output wire stall_ex,

    input wire [`AluSelBus] alusel,
    input wire [`AluOpBus] aluop,
    input wire [`RegBus] op1,
    input wire [`RegBus] op2,
    input wire [`RegBus] link_addr,
    input wire write_i,
    input wire [`RegAddrBus] regw_addr_i,
    input wire [`RegBus] mem_offset,
    input wire [`MemAddrBus] br_addr_i,
    input wire [`MemAddrBus] br_offset,

    output reg write_o,
    output reg [`RegAddrBus] regw_addr_o,
    output reg [`RegBus] regw_data,

    output reg load,
    output reg store,
    output reg [`RegBus] mem_write_data,
    output reg [2:0] mem_length,
    output reg mem_signed,

    input wire no_prediction,
    input wire prediction,
    input wire [`MemAddrBus] pc,
    output reg br_inst,
    output wire [`MemAddrBus] br_addr_o,
    output reg br,
    output wire br_error,
    output wire [`MemAddrBus] br_actual_addr
);

    assign br_error = (br_inst && br != prediction) || (no_prediction && br);
    assign br_actual_addr = br ? br_addr_o:pc+4;

    assign stall_ex = 0;

    reg [`RegBus] logic_ret;
    reg [`RegBus] arith_ret;
    reg [`RegBus] shift_ret;
    reg [`RegBus] mem_ret;
    wire [`RegBus] jump_ret;

    always @(*) begin
        logic_ret = 0;
        if (!reset && alusel == 3'b001) begin
            case (aluop)
                0: logic_ret = op1 | op2;
                1: logic_ret = op1 & op2;
                2: logic_ret = op1 ^ op2;
            endcase
        end
    end

    always @(*) begin
        shift_ret = 0;
        if (!reset && alusel == 3'b010) begin
            case (aluop)
                0: shift_ret = op1 << op2[4:0];
                1: shift_ret = op1 >> op2[4:0];
                2: shift_ret = ({32{op1[31]}} << (32-op2[4:0])) | (op1 >> op2[4:0]);
            endcase
        end
    end

    always @(*) begin
        arith_ret = 0;
        if (!reset && alusel == 3'b100) begin
            case (aluop)
                0: arith_ret = op1+op2;
                1: arith_ret = op1-op2;
                2: arith_ret = $signed(op1) < $signed(op2);
                3: arith_ret = op1 < op2;
            endcase
        end
    end

    assign br_addr_o = br_addr_i+br_offset;
    assign jump_ret = link_addr+4;

    always @(*) begin
        br = 0; br_inst = 0;
        if (!reset) begin
            if (alusel == 3'b101) begin
                case (aluop)
                    0: br = op1 == op2;
                    1: br = op1 != op2;
                    2: br = $signed(op1) < $signed(op2);
                    3: br = $signed(op1) >= $signed(op2);
                    4: br = op1 < op2;
                    5: br = op1 >= op2;
                endcase
                br_inst = 1;
            end else if (alusel == 3'b110) begin
                br = 1; br_inst = !no_prediction;
            end
        end
    end

    always @(*) begin
        load = 0;
        store = 0;
        mem_ret = 0;
        mem_signed = 0;
        mem_length = 0;
        mem_write_data = 0;
        if (!reset && alusel == 3'b111) begin
            case (aluop)
                0: begin load = 1; mem_length = 1; mem_signed = 1; end // LB
                1: begin load = 1; mem_length = 2; mem_signed = 1; end // LH
                2: begin load = 1; mem_length = 4; mem_signed = 1; end // LW
                3: begin load = 1; mem_length = 1; mem_signed = 0; end // LBU
                4: begin load = 1; mem_length = 2; mem_signed = 0; end // LHU
                5: begin store = 1; mem_length = 1; mem_write_data = op2; end // SB
                6: begin store = 1; mem_length = 2; mem_write_data = op2; end // SH
                7: begin store = 1; mem_length = 4; mem_write_data = op2; end // SW
            endcase
            mem_ret = op1+mem_offset;
        end
    end

    always @(*) begin
        regw_data = 0;
        if (reset) begin
            write_o = 0;
            regw_addr_o = 0;
        end else begin
            write_o = write_i;
            regw_addr_o = regw_addr_i;
            case (alusel)
                3'b001: regw_data = logic_ret; // LOGIC
                3'b010: regw_data = shift_ret; // SHIFT
                3'b100: regw_data = arith_ret; // ARITH
                3'b110: regw_data = jump_ret; // JUMP
                3'b111: regw_data = mem_ret; // MEM
            endcase
        end
    end

endmodule
