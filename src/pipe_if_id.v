`include "define.v"

module pipe_if_id(
    input wire clock,
    input wire reset,

    input wire [`MemAddrBus] pc_i,
    input wire [`InstBus] inst_i,

    output reg [`MemAddrBus] pc_o,
    output reg [`InstBus] inst_o
);

    always @(posedge clock) begin
        if (reset == 1) begin
            pc_o <= 0;
            inst_o <= 0;
        end else begin
            pc_o <= pc_i;
            inst_o <= inst_i;
        end
    end

endmodule