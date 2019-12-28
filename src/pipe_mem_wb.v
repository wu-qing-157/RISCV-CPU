`include "define.v"

module pipe_mem_wb(
    input wire clock,
    input wire reset,

    input wire [5:4] stall,

    input wire write_i,
    input wire [`RegAddrBus] regw_addr_i,
    input wire [`RegBus] regw_data_i,

    output reg write_o,
    output reg [`RegAddrBus] regw_addr_o,
    output reg [`RegBus] regw_data_o
);

    always @(posedge clock) begin
        if (reset || (stall[4] && !stall[5])) begin
            write_o <= 0;
            regw_addr_o <= 0;
            regw_data_o <= 0;
        end else if (!stall[4] && !stall[5]) begin
            write_o <= write_i;
            regw_addr_o <= regw_addr_i;
            regw_data_o <= regw_data_i;
        end
    end

endmodule
