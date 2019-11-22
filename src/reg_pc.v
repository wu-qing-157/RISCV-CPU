`include "define.v"

module reg_pc(
    input wire clock,
    input wire reset,

    output reg [`MemAddrBus] pc_o
);

    reg [`MemAddrBus] pc;

    initial begin
        pc <= 0;
    end

    always @(posedge clock) begin
        if (reset == 1) begin
            pc <= 0;
            pc_o <= 0;
        end else begin
            pc_o <= pc;
            pc <= pc+4;
        end
    end

endmodule
