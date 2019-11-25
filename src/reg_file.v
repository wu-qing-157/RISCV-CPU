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

    initial begin
        // TODO for difficulties when making test data
        regs[0] <= 0;
        regs[1] <= 0;
        regs[2] <= 0;
        regs[3] <= 0;
        regs[4] <= 0;
        regs[5] <= 0;
        regs[6] <= 0;
        regs[7] <= 0;
        regs[8] <= 0;
        regs[9] <= 0;
        regs[10] <= 0;
        regs[11] <= 0;
        regs[12] <= 0;
        regs[13] <= 0;
        regs[14] <= 0;
        regs[15] <= 0;
        regs[16] <= 0;
        regs[17] <= 0;
        regs[18] <= 0;
        regs[19] <= 0;
        regs[20] <= 0;
        regs[21] <= 0;
        regs[22] <= 0;
        regs[23] <= 0;
        regs[24] <= 0;
        regs[25] <= 0;
        regs[26] <= 0;
        regs[27] <= 0;
        regs[28] <= 0;
        regs[29] <= 0;
        regs[30] <= 0;
        regs[31] <= 0;
    end

    always @(posedge clock) begin
        if (reset == 0 && write == 1 && regw_addr != 0)
            regs[regw_addr] <= regw_data;
    end

    always @(*) begin
        if (reset == 1 || read1 == 0 || reg1_addr == 0)
            reg1_data <= 0;
        else if (write && regw_addr == reg1_addr)
            reg1_data <= regw_data;
        else
            reg1_data <= regs[reg1_addr];
    end

    always @(*) begin
        if (reset == 1 || read2 == 0 || reg2_addr == 0)
            reg2_data <= 0;
        else if (write && regw_addr == reg2_addr)
            reg2_data <= regw_data;
        else
            reg2_data <= regs[reg2_addr];
    end

endmodule
