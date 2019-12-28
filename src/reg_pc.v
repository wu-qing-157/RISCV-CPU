`include "define.v"

module reg_pc(
    input wire clock,
    input wire reset,

    input wire stall0,

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
        end else begin
            sending <= 1;
            if (br) begin
                pc <= br_addr+4;
                pc_o <= br_addr;
            end else if (!stall0) begin
                pc <= pc+4;
                pc_o <= pc;
            end
        end
    end

endmodule
