`include "define.v"

module ex_mem(
    input wire clock,
    input wire reset,

    input wire ex_write,
    input wire[`RegAddressBus] ex_write_address,
    input wire[`RegBus] ex_write_data,

    output reg mem_write,
    output reg[`RegAddressBus] mem_write_address,
    output reg[`RegBus] mem_write_data
);

    always@(posedge clock) begin
        if (reset == 1) begin
            mem_write <= 0;
            mem_write_address <= 0;
            mem_write_data <= 0;
        end else begin
            mem_write <= ex_write;
            mem_write_address <= ex_write_address;
            mem_write_data <= ex_write_data;
        end
    end

endmodule