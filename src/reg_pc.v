`include "define.v"

module reg_pc(
    input wire clock,
    input wire reset,

    input wire stall,

    input wire br,
    input wire [`MemAddrBus] br_addr,
    output reg [`MemAddrBus] pc_o
);

    reg [`MemAddrBus] pc;

    initial begin
        pc <= 0;
    end

    always @(posedge clock) begin
        if (br) begin
            pc <= br_addr;
        end else if (!stall[0]) begin
            pc <= pc+4;
        end
        if (reset) begin
            pc <= 4;
            pc_o <= 0;
        end else if (!stall[0]) begin
            pc_o <= pc;
        end
    end

endmodule
