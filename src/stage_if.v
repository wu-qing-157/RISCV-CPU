`include "define.v"

module stage_if(
    input wire reset,

    output wire stall_if,

    input wire [`MemAddrBus] pc_i,

    output reg ram_read,
    output reg [`MemAddrBus] ram_addr,
    input wire ram_ready,
    input wire [`InstBus] ram_data,

    output reg [`MemAddrBus] pc_o,
    output reg [`InstBus] inst_o
);

    reg [`MemAddrBus] pc;

    assign stall_if = !ram_ready;

    always @(*) begin
        if (reset) begin
            pc_o = 0; ram_read = 0; ram_addr = 0;
        end else begin
            pc_o = pc_i; ram_read = 1; ram_addr = pc_i;
        end
    end

    always @(*) begin
        if (!reset && ram_ready) begin
            inst_o = ram_data;
        end else begin
            inst_o = 0;
        end
    end

endmodule
