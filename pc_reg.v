`include "define.v"

module pc_reg(
    input wire clock,
    input wire reset,
    
    output reg[`InstructionAddressBus] pc,
    output reg ce
);

    always@(posedge clock) begin
        if (reset == 1) begin
            ce <= 0;
        end else begin
            ce <= 1;
        end
    end

    always@(posedge clock) begin
        if (ce == 0) begin
            pc <= 32'h00000000;
        end else begin
            pc <= pc + 4;
        end
    end

endmodule