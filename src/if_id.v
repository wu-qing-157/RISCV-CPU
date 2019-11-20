`include "define.v"

module if_id(
    input wire clock,
    input wire reset,

    input wire[`InstructionAddressBus] if_pc,
    input wire[`InstructionBus] if_instruction,
    
    output reg[`InstructionAddressBus] id_pc,
    output reg[`InstructionBus] id_instruction
);

    always@(posedge clock) begin
        if (reset == 1) begin
            id_pc <= 0;
            id_instruction <= 0;
        end else begin
            id_pc <= if_pc;
            id_instruction <= if_instruction;
        end
    end

endmodule