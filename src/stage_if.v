`include "define.v"

module stage_if(
    input wire reset,

    output reg stall_if,

    input wire [`MemAddrBus] pc_i,

    input wire br,
    input wire [`MemAddrBus] br_addr,

    input wire ram_busy,
    output reg ram_read,
    output reg [`MemAddrBus] ram_addr_o,
    input wire ram_ready,
    input wire [`MemAddrBus] ram_addr_i,
    input wire [`InstBus] ram_data_i,

    output reg [`MemAddrBus] pc_o,
    output reg [`InstBus] inst_o
);

    always @(*) begin
        if (reset) begin
            pc_o = 0;
        end else if (br) begin
            pc_o = br_addr;
        end else begin
            pc_o = pc_i;
        end
    end

    always @(*) begin
        ram_read = 0;
        ram_addr_o = 0;
        stall_if = 0;
        if (reset) begin
            inst_o = 0;
        end else begin
            if (ram_ready && pc_o == ram_addr_i) begin
                inst_o = ram_data_i;
            end else begin
                stall_if = 1;
                if (!ram_busy) begin
                    ram_read = 1;
                    ram_addr_o = pc_o;
                end
            end
        end
    end

endmodule
