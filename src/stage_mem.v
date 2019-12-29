`include "define.v"

module stage_mem(
    input wire reset,

    output wire stall_mem,

    input wire load,
    input wire store,
    input wire [`MemAddrBus] addr,
    input wire [`RegBus] data,
    input wire [2:0] length,
    input wire signed_,

    input wire ram_ready,
    output reg [`MemAddrBus] ram_addr,
    input wire [`MemDataBus] ram_data_i,
    output reg [`MemDataBus] ram_data_o,
    output reg [2:0] ram_length,
    output reg ram_signed,

    output reg ram_read,
    output reg ram_write,

    input wire write_i,
    input wire [`RegAddrBus] regw_addr_i,
    input wire [`RegBus] regw_data_i,

    output reg write_o,
    output reg [`RegAddrBus] regw_addr_o,
    output reg [`RegBus] regw_data_o
);

    assign stall_mem = (load || store) && !ram_ready;

    always @(*) begin
        write_o = write_i;
        regw_addr_o = regw_addr_i;
        ram_read = 0;
        ram_write = 0;
        ram_addr = 0;
        ram_length = 0;
        ram_signed = 0;
        ram_data_o = 0;
        if (reset) begin
            write_o = 0;
            regw_addr_o = 0;
        end else if (load) begin
            ram_read = 1;
            ram_addr = addr;
            ram_length = length;
            ram_signed = signed_;
        end else if (store) begin
            ram_write = 1;
            ram_addr = addr;
            ram_length = length;
            ram_data_o = data;
        end
    end

    always @(*) begin
        if (reset) begin
            regw_data_o = 0;
        end else if (!load) begin
            regw_data_o = regw_data_i;
        end else begin
            regw_data_o = ram_data_i;
        end
    end

endmodule
