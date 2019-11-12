`include "define.v"

module mem(
    input wire reset,

    input wire write,
    input wire[`RegAddressBus] write_address,
    input wire[`RegBus] write_data,

    output reg write_o,
    output reg[`RegAddressBus] write_address_o,
    output reg[`RegBus] write_data_o
);

    always@(*) begin
        if (reset == 1) begin
            write_o <= 0;
            write_address_o <= 0;
            write_data_o <= 0;
        end else begin
            write_o <= write;
            write_address_o <= write_address;
            write_data_o <= write_data;
        end
    end

endmodule