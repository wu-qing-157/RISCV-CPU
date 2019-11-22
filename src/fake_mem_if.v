`include "define.v"

module fake_mem_if(
    input wire reset,

    input wire [`MemAddrBus] pc,
    output reg [`InstBus] inst
);

    always @(*) begin
        if (reset == 1) begin
            inst <= 0;
        end else begin
            case (pc)
                0 : inst <= 32'b000000000011_00000_110_00001_0010011;
                4 : inst <= 32'b111111110000_00000_110_00010_0010011;
                8 : inst <= 32'b111111111111_00000_110_00011_0010011;
                12 : inst <= 32'b111100001100_00001_110_00100_0010011;
                default : inst <= 0;
            endcase
        end
    end

endmodule
