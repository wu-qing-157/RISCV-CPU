`include "define.v"

module rom(
    input wire ce,
    input wire[`InstructionAddressBus] pc,
    output reg[`InstructionBus] instruction
);

    reg[`InstructionBus] instructions[0:`InstructionNum - 1];

    initial $readmemh("instructions.data", instructions);

    always@(*) begin
        if (ce == 0) begin
            instruction <= 0;
        end else begin
            instruction <= instructions[pc[`InstructionNumLog2 + 1:2]];
        end
    end

endmodule