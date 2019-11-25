`include "define.v"

module stage_ex(
    input wire reset,

    output reg stall_ex,

    input wire [`AluSelBus] alusel,
    input wire [`AluOpBus] aluop,
    input wire [`RegBus] op1,
    input wire [`RegBus] op2,
    input wire [`RegBus] link_addr,
    input wire write_i,
    input wire [`RegAddrBus] regw_addr_i,
    input wire [`RegBus] mem_offset,

    output reg write_o,
    output reg [`RegAddrBus] regw_addr_o,
    output reg [`RegBus] regw_data,

    output reg load,
    output reg store,
    output reg [`RegBus] mem_write_data,
    output reg [2:0] mem_length,
    output reg mem_signed
);

    reg [`RegBus] logic_ret;
    reg [`RegBus] arith_ret;
    reg [`RegBus] shift_ret;
    reg [`RegBus] mem_ret;

    always @(*) begin
        if (reset || alusel != 3'b001) begin
            logic_ret <= 0;
        end else begin
            case (aluop)
                0: logic_ret <= op1 | op2;
                1: logic_ret <= op1 & op2;
                2: logic_ret <= op1 ^ op2;
            endcase
        end
    end

    always @(*) begin
        if (reset || alusel != 3'b010) begin
            shift_ret <= 0;
        end else begin
            case (aluop)
                0: shift_ret <= op1 << op2[4:0];
                1: shift_ret <= op1 >> op2[4:0];
                2: shift_ret <= ({32{op1[31]}} << (32-op2[4:0])) | (op1 >> op2[4:0]);
            endcase
        end
    end

    always @(*) begin
        if (reset || alusel != 3'b100) begin
            arith_ret <= 0;
        end else begin
            case (aluop)
                0: arith_ret <= op1+op2;
                1: arith_ret <= op1-op2;
                2: arith_ret <= $signed(op1) < $signed(op2);
                3: arith_ret <= op1 < op2;
            endcase
        end
    end

    always @(*) begin
        if (reset || alusel != 3'b111) begin
            load <= 0;
            store <= 0;
            mem_ret <= 0;
        end else begin
            case (aluop)
                0: begin
                    load <= 1; mem_length <= 1; mem_signed <= 1;
                end // LB
                1: begin
                    load <= 1; mem_length <= 2; mem_signed <= 1;
                end // LH
                2: begin
                    load <= 1; mem_length <= 4; mem_signed <= 1;
                end // LW
                3: begin
                    load <= 1; mem_length <= 1; mem_signed <= 0;
                end // LBU
                4: begin
                    load <= 1; mem_length <= 2; mem_signed <= 0;
                end // LHU
                5: begin
                    store <= 1; mem_length <= 1; mem_write_data <= op1;
                end // SB
                6: begin
                    store <= 1; mem_length <= 2; mem_write_data <= op1;
                end
                7: begin
                    store <= 1; mem_length <= 4; mem_write_data <= op1;
                end
            endcase
            mem_ret <= op1+mem_offset;
        end
    end

    always @(*) begin
        stall_ex <= 0;
        if (reset) begin
            write_o <= 0;
            regw_addr_o <= 0;
            regw_data <= 0;
        end else begin
            case (alusel)
                3'b000: begin
                    regw_data <= 0;
                end
                3'b001: begin
                    regw_data <= logic_ret;
                end
                3'b010: begin
                    regw_data <= shift_ret;
                end
                3'b100: begin
                    regw_data <= arith_ret;
                end
                3'b110: begin
                    regw_data <= link_addr;
                end
                3'b111: begin
                    regw_data <= mem_ret;
                end
            endcase
        end
    end

endmodule: stage_ex
