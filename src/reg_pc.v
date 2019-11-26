`include "define.v"

module reg_pc(
    input wire clock,
    input wire reset,

    input wire [`StallBus] stall,

    input wire br,
    input wire [`MemAddrBus] br_addr,
    output reg sending,
    output reg [`MemAddrBus] pc_o
);

    reg [`MemAddrBus] pc;

    initial begin
        pc <= 0;
    end

    always @(posedge clock) begin
        if (reset) begin
            pc <= 0;
            sending <= 0;
        end else if (br) begin
            pc <= br_addr+4;
            pc_o <= br_addr;
            sending <= 1;
        end else if (!stall[0]) begin
            pc <= pc+4;
            pc_o <= pc;
            sending <= 1;
        end
    end

endmodule
