`include "define.v"

module stage_if(
    input wire reset,

    output reg stall_if,

    input wire receiving,
    input wire [`MemAddrBus] pc_i,

    input wire br,
    input wire [`MemAddrBus] br_addr,

    input wire ram_busy,
    input wire [2:0] ram_waiting_time,
    output reg ram_read,
    output reg [`MemAddrBus] ram_addr,
    input wire ram_ready,
    input wire [`InstBus] ram_data,

    output reg [`MemAddrBus] pc_o,
    output reg [`InstBus] inst_o
);

    reg complete;
    reg [`MemAddrBus] pc;

    initial begin
        ram_read = 0;
        complete = 0;
        pc = 0;
    end

    always @(*) begin
        if (reset) begin
            complete = 0;
            pc_o = 0;
        end else begin
            if (br) begin
                pc_o = br_addr;
                if (pc != pc_o) complete = 0;
            end else if (receiving) begin
                pc_o = pc_i;
                if (pc != pc_o) complete = 0;
            end
            if (ram_ready && pc == pc_o) begin
                complete = 1;
                stall_if = 0;
                inst_o = ram_data;
            end
            if (receiving && !complete) begin
                stall_if = 1;
            end
            if (receiving && (!ram_busy || ram_waiting_time <= 1)) begin
                ram_read = 1;
                pc = complete ? pc_o+4:pc_o;
                ram_addr = pc;
            end
        end
    end

endmodule
