`include "define.v"

module stage_if(
    input wire reset,

    output wire stall_if,
    input wire stall2,

    input wire receiving,
    input wire [`MemAddrBus] pc_i,

    input wire id_br,
    input wire ex_br,
    input wire [`MemAddrBus] br_addr,

    output reg ram_read,
    output reg [`MemAddrBus] ram_addr,
    input wire ram_ready,
    input wire [`InstBus] ram_data,

    output reg [`MemAddrBus] pc_o,
    output reg [`InstBus] inst_o
);

    reg [`MemAddrBus] pc;

    assign stall_if = id_br || ((ex_br || receiving) && !ram_ready);

    initial begin
        ram_read = 0;
    end

    always @(*) begin
        if (reset || id_br) begin
            pc_o = 0;
            ram_read = 0; ram_addr = 0;
        end else begin
            if (ex_br && !stall2) begin
                pc_o = br_addr;
            end else if (receiving) begin
                pc_o = pc_i;
            end else begin
                pc_o = 0;
            end
            if (ex_br || receiving) begin
                ram_read = 1; ram_addr = pc_o;
            end else begin
                ram_read = 0; ram_addr = 0;
            end
        end
    end

    always @(*) begin
        if (reset) begin
            inst_o = 0;
        end if (ram_ready) begin
            inst_o = ram_data;
        end else begin
            inst_o = 0;
        end
    end

endmodule
