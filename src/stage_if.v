`include "define.v"

module stage_if(
    input wire reset,

    input wire [`MemAddrBus] pc_i,

    output reg [`MemAddrBus] pc_o,
    input wire [`InstBus] mem_data_i,
    output reg [`InstBus] inst_o
);

    always @(*) begin
        if (reset) begin
            pc_o <= 0;
        end else begin
            pc_o <= pc_i;
        end
    end

    always @(*) begin
        if (reset) begin
            inst_o <= 0;
        end else begin
            inst_o <= mem_data_i;
        end
    end

endmodule
