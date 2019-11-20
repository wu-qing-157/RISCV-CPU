`include "define.v"

module mem_wb(
    input wire clock,
    input wire reset,

    input wire mem_write,
    input wire[`RegAddressBus] mem_write_address,
    input wire[`RegBus] mem_write_data,

    output reg wb_write,
    output reg[`RegAddressBus] wb_write_address,
    output reg[`RegBus] wb_write_data
);

    always@(posedge clock) begin
        if (reset == 1) begin
            wb_write <= 0;
            wb_write_address <= 0;
            wb_write_data <= 0;
        end else begin
            wb_write <= mem_write;
            wb_write_address <= mem_write_address;
            wb_write_data <= mem_write_data;
        end
    end

endmodule