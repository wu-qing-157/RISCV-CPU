`include "define.v"

module regfile(
    input wire clock,
    input wire reset,

    input wire write,
    input wire[`RegAddressBus] write_address,
    input wire[`RegBus] write_data,

    input wire read1,
    input wire[`RegAddressBus] read1_address,
    output reg[`RegBus] read1_data,

    input wire read2,
    input wire[`RegAddressBus] read2_address,
    output reg[`RegBus] read2_data
);

    reg[`RegBus] regs[0:`RegNum - 1];

    always@(posedge clock) begin
        if (reset == 0) begin
            if (write == 1 && write_address != 0) begin
                regs[write_address] <= write_data;
            end
        end
    end

    always@(*) begin
        if (reset == 1 || read1 == 0 || read1_address == 0) begin
            read1_data <= 0;
        end else if (write == 1 && read1_address == write_address) begin
            read1_data <= write_data;
        end else begin
            read1_data <= regs[read1_address];
        end
    end

    always@(*) begin
        if (reset == 1 || read2 == 0 || read2_address == 0) begin
            read2_data <= 0;
        end else if (write == 1 && read2_address == write_address) begin
            read2_data <= write_data;
        end else begin
            read2_data <= regs[read2_address];
        end
    end

endmodule