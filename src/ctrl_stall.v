`include "define.v"

module ctrl_stall(
    input wire reset,
    input wire stall_if,
    input wire stall_id,
    input wire stall_ex,
    input wire stall_mem,

    output reg [`StallBus] stall
);

    always @(*) begin
        if (reset)
            stall = 6'b000000;
        else if (stall_mem)
            stall = 6'b011111;
        else if (stall_ex)
            stall = 6'b001111;
        else if (stall_id)
            stall = 6'b000111;
        else if (stall_if)
            stall = 6'b000011;
        else
            stall = 6'b000000;
    end

endmodule
