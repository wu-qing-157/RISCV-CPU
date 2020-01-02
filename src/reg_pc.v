`include "define.v"

module reg_pc(
    input wire clock,
    input wire reset,

    input wire stall0,

    input wire [`MemAddrBus] pc_i,
    input wire br,
    input wire [`MemAddrBus] br_addr,
    output reg [`MemAddrBus] pc_o
);

    always @(posedge clock) begin
        if (reset) begin
            pc_o <= 0;
        end else if (br) begin
            pc_o <= br_addr;
        end else if (!stall0) begin
            pc_o <= pc_i;
        end
    end

endmodule
