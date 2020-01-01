`include "define.v"

module buffer_write(
    input wire clock,
    input wire reset,

    input wire write,
    output wire busy,
    input wire [2:0] length,
    input wire [`MemAddrBus] addr,
    input wire [`MemDataBus] data,

    input wire ram_busy,
    input wire ram_seccess,
    output wire ram_write,
    output wire [`MemAddrBus] ram_addr,
    output wire [`ByteBus] ram_data
);

    wire [`ByteBus] write_data[3:0];
    assign write_data[0] = data[7:0];
    assign write_data[1] = data[15:8];
    assign write_data[2] = data[23:16];
    assign write_data[3] = data[31:24];

    reg working;
    reg [2:0] cur;

    assign ram_addr = addr+cur;
    assign ram_data = write_data[cur];

    assign busy = write || working;
    assign ram_write = busy && !ram_busy;

    always @(posedge clock) begin
        if (reset) begin
            cur <= 0;
            working <= 0;
        end else if (write) begin
            if (cur+ram_seccess == length) begin
                cur <= 0;
                working <= 0;
            end else begin
                cur <= cur+ram_seccess;
                working <= 1;
            end
        end else if (ram_write) begin
            if (cur+ram_seccess == length) begin
                cur <= 0;
                working <= 0;
            end else begin
                cur <= cur+ram_seccess;
            end
        end
    end

endmodule
