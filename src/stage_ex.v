`include "define.v"

module stage_ex(
    input wire reset,

    input wire [`AluSelBus] alusel,
    input wire [`AluOpBus] aluop,
    input wire [`RegBus] op1,
    input wire [`RegBus] op2,
    input wire write_i,
    input wire [`RegAddrBus] regw_addr_i,

    output reg write_o,
    output reg [`RegAddrBus] regw_addr_o,
    output reg [`RegBus] regw_data
);

    reg [`RegBus] logic_ret;
    reg [`RegBus] arith_ret;
    reg [`RegBus] shift_ret;

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
                2: shift_ret <= ({32{op1[31]}} << (32 - op2[4:0])) | (op1 >> op2[4:0]);
            endcase
        end
    end

    always @(*) begin
        if (reset || alusel != 3'b100) begin
            arith_ret <= 0;
        end else begin
            case (aluop)
                0: arith_ret <= op1 + op2;
                1: arith_ret <= op1 - op2;
                2: arith_ret <= $signed(op1) < $signed(op2);
                3: arith_ret <= op1 < op2;
            endcase
        end
    end

    always @(*) begin
        write_o <= write_i;
        regw_addr_o <= regw_addr_i;
        case (alusel)
            3'b001: begin
                regw_data <= logic_ret;
            end
            3'b010: begin
                regw_data <= shift_ret;
            end
            3'b100: begin
                regw_data <= arith_ret;
            end
        endcase
    end

endmodule
