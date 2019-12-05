`include "define.v"

module pipe_ex_mem(
    input wire clock,
    input wire reset,

    input wire [4:3] stall,

    input wire write_i,
    input wire [`RegAddrBus] regw_addr_i,
    input wire [`RegBus] regw_data_i,
    input wire load_i,
    input wire store_i,
    input wire [`MemDataBus] mem_write_data_i,
    input wire [2:0] mem_length_i,
    input wire mem_signed_i,

    output reg write_o,
    output reg [`RegAddrBus] regw_addr_o,
    output reg [`RegBus] regw_data_o,
    output reg load_o,
    output reg store_o,
    output reg [`MemDataBus] mem_write_data_o,
    output reg [2:0] mem_length_o,
    output reg mem_signed_o
);

    always @(posedge clock) begin
        if (reset || (stall[3] && !stall[4])) begin
            write_o <= 0;
            regw_addr_o <= 0;
            regw_data_o <= 0;
            load_o <= 0;
            store_o <= 0;
            mem_write_data_o <= 0;
            mem_length_o <= 0;
            mem_signed_o <= 0;
        end else if (!stall[3] && !stall[4]) begin
            write_o <= write_i;
            regw_addr_o <= regw_addr_i;
            regw_data_o <= regw_data_i;
            load_o <= load_i;
            store_o <= store_i;
            mem_write_data_o <= mem_write_data_i;
            mem_length_o <= mem_length_i;
            mem_signed_o <= mem_signed_i;
        end
    end

endmodule
