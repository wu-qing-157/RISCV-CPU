`include "define.v"

module reg_pc(
    input wire clock,
    input wire reset,

    input wire stall0,
    input wire stall2,

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
        end else if (br && !stall2) begin
            if (!stall0) begin
                pc <= br_addr+8;
                pc_o <= br_addr+4;
            end else begin
                pc <= br_addr+4;
                pc_o <= br_addr;
            end
            sending <= 1;
        end else if (!stall0) begin
            pc <= pc+4;
            pc_o <= pc;
            sending <= 1;
        end
    end

endmodule
