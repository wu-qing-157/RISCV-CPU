`include "define.v"

module stage_if(
    input wire reset,

    output reg stall_if,
    input wire [`StallBus] stall,

    input wire receiving,
    input wire [`MemAddrBus] pc_i,

    input wire br,
    input wire [`MemAddrBus] br_addr,

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
    end

    always @(*) begin
        if (reset) begin
            complete = 0;
            pc_o = 0;
            inst_o = 0;
        end else begin
            if (br && !stall[2]) begin
                pc_o = br_addr;
            end else if (receiving) begin
                pc_o = pc_i;
            end
            if (br || receiving) begin
                ram_read = 1;
                ram_addr = pc_o;
                if (ram_ready && !stall[2]) begin
                    stall_if = 0;
                    inst_o = ram_data;
                    ram_read = 0;
                end else begin
                    stall_if = 1;
                end
            end
        end
    end

endmodule
