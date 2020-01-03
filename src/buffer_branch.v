`include "define.v"

module buffer_branch(
    input wire reset,
    input wire clock,

    input wire [`MemAddrBus] pc_i,
    output reg [`MemAddrBus] pc_o,
    output reg prediction,

    input wire update,
    input wire committed,
    input wire [`BTBAllBytes] current,
    input wire [`MemAddrBus] target
);

    reg [`BTBNum-1:0] btb_valid;
    reg [`BTBTagBus] btb_tag [`BTBNum-1:0];
    reg [`MemAddrBus] btb_target [`BTBNum-1:0];
    reg [1:0] btb_predictor [`BTBNum-1:0];

    wire [`BTBBus] pc_index = pc_i[`BTBBus];
    wire [`BTBTagBus] pc_tag = pc_i[`BTBTagBytes];

    always @(*) begin
        if (reset) begin
            pc_o = 0;
            prediction = 0;
        end else if (btb_valid[pc_index] && btb_tag[pc_index] == pc_tag && btb_predictor[pc_index][1]) begin
            pc_o = btb_target[pc_index];
            prediction = 1;
        end else begin
            pc_o = pc_i+4;
            prediction = 0;
        end
    end

    wire [`BTBBus] current_index = current[`BTBBus];
    wire [`BTBTagBus] current_tag = current[`BTBTagBytes];

    always @(posedge clock) begin
        if (reset) begin
            btb_valid <= 0;
        end else if (update) begin
            if (btb_valid[current_index] && btb_tag[current_index] == current_tag) begin
                if (committed && btb_predictor[current_index] != 3)
                    btb_predictor[current_index] <= btb_predictor[current_index]+1;
                if (!committed && btb_predictor[current_index] != 0)
                    btb_predictor[current_index] <= btb_predictor[current_index]-1;
            end else begin
                btb_valid[current_index] <= 1;
                btb_tag[current_index] <= current_tag;
                btb_target[current_index] <= target;
                btb_predictor[current_index] <= committed ? 2:1;
            end
        end
    end

endmodule
