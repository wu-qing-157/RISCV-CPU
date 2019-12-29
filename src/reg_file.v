`include "define.v"

module reg_file(
    input wire clock,
    input wire reset,

    input wire write,
    input wire [`RegAddrBus] regw_addr,
    input wire [`RegBus] regw_data,

    input wire read1,
    input wire [`RegAddrBus] reg1_addr,
    output reg [`RegBus] reg1_data,

    input wire read2,
    input wire [`RegAddrBus] reg2_addr,
    output reg [`RegBus] reg2_data
);

    reg [`RegBus] regs [`RegNum-1:0];
    reg [31:0] i;

    initial begin
        // TODO for difficulties when making test data
        for (i = 0; i < 32; i = i+1) regs[i] <= 0;
    end

    always @(posedge clock) begin
        if (reset == 0 && write == 1 && regw_addr != 0) regs[regw_addr] <= regw_data;
    end

    always @(*) begin
        if (reset == 1 || read1 == 0 || reg1_addr == 0)
            reg1_data = 0;
        else if (write && regw_addr == reg1_addr)
            reg1_data = regw_data;
        else
            reg1_data = regs[reg1_addr];
    end

    always @(*) begin
        if (reset == 1 || read2 == 0 || reg2_addr == 0)
            reg2_data = 0;
        else if (write && regw_addr == reg2_addr)
            reg2_data = regw_data;
        else
            reg2_data = regs[reg2_addr];
    end

endmodule
