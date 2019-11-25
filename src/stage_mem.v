`include "define.v"

module stage_mem(
    input wire reset,

    output reg stall_mem,

    input wire load,
    input wire store,
    input wire [`MemAddrBus] addr,
    input wire [`RegBus] data,
    input wire [2:0] length,
    input wire signed_,

    input wire ram_busy,
    input wire ram_ready,
    output reg [`MemAddrBus] ram_addr,
    input wire [`MemDataBus] ram_data_i,
    output reg [`MemDataBus] ram_data_o,
    output reg [2:0] ram_length,
    output reg ram_signed,

    output wire ram_read,
    output wire ram_write,

    input wire write_i,
    input wire [`RegAddrBus] regw_addr_i,
    input wire [`RegBus] regw_data_i,

    output reg write_o,
    output reg [`RegAddrBus] regw_addr_o,
    output reg [`RegBus] regw_data_o
);

    always @(*) begin
        ram_read = 0;
        mem_write = 0;
        if (reset) begin
            stall_mem <= 0;
            write_o <= 0;
            regw_addr_o <= 0;
            regw_data_o <= 0;
        end else if (load) begin
            if (ram_ready) begin
                regw_data_o <= ram_data_i;
            end else begin
                stall_mem <= 1;
                if (!ram_busy) begin
                    ram_read <= 1;
                    ram_addr_o <= addr;
                    ram_length <= length;
                    ram_signed <= signed_;
                end
            end
        end else if (store) begin
            if (ram_busy) begin
                stall_mem <= 1;
            end else begin
                ram_write <= 1;
                ram_addr_o <= addr;
                ram_data_o <= data;
                ram_length <= length;
            end
        end else begin
            write_o <= write_i;
            regw_addr_o <= regw_addr_i;
            regw_data_o <= regw_data_i;
        end
    end

endmodule: stage_mem
