`include "define.v"

module ex(
    input wire reset,

    input wire[`AluOpBus] aluop,
    input wire[`AluSelBus] alusel,
    input wire[`RegBus] reg1,
    input wire[`RegBus] reg2,
    input wire write,
    input wire[`RegAddressBus] write_address,

    output reg write_o,
    output reg[`RegAddressBus] write_address_o,
    output reg[`RegBus] write_data
);

    reg[`RegBus] logic_out;

    always@(*) begin
        if (reset == 1) begin
            logic_out <= 0;
        end else begin
            case (aluop)
                `EXEOP_OR: logic_out <= reg1 | reg2;
                default: logic_out <= 0;
            endcase
        end
    end

    always@(*) begin
        write_o <= write;
        write_address_o <= write_address;
        case (alusel)
            `EXERES_LOGIC: write_data <= logic_out;
            default: write_data <= 0;
        endcase
    end

endmodule