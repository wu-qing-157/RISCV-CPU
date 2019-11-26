`include "define.v"

module ctrl_mem(
    input wire clock,
    input wire reset,

    input wire if_read,
    input wire [`MemAddrBus] if_addr,

    input wire mem_read,
    input wire mem_write,
    input wire [`MemAddrBus] mem_addr,
    input wire [`MemDataBus] mem_data_i,
    input wire [2:0] mem_length,
    input wire mem_signed,

    output wire ram_rw,
    output wire [`MemAddrBus] ram_addr,
    output wire [`ByteBus] ram_w_data,
    input wire [`ByteBus] ram_r_data,

    output reg if_busy,
    output reg if_ready,
    output reg [`MemDataBus] if_data,

    output reg mem_busy,
    output reg mem_ready,
    output reg [`MemDataBus] mem_data_o
);

    reg writing;
    reg [2:0] cur;
    reg [`ByteBus] ret [2:0];

    wire [2:0] tot = (mem_read || mem_write) ? mem_length:if_read ? 4:0;
    wire [`MemAddrBus] addr = (mem_read || mem_write) ? mem_addr:if_read ? if_addr:0;

    wire [`ByteBus] write_data[3:0];
    assign write_data[0] = mem_data_i[7:0];
    assign write_data[1] = mem_data_i[15:8];
    assign write_data[2] = mem_data_i[23:16];
    assign write_data[3] = mem_data_i[31:24];

    assign ram_rw = mem_write;
    assign ram_addr = addr+cur;
    assign ram_w_data = write_data[cur];

    initial begin
        cur <= 0;
        if_busy <= 0;
        mem_busy <= 0;
        if_ready <= 0;
        mem_ready <= 0;
    end

    always @(posedge clock) begin
        if (reset) begin
            cur <= 0;
            if_busy <= 0;
            if_ready <= 0;
            mem_busy <= 0;
            mem_ready <= 0;
        end else if (tot && !ram_rw) begin
            if (cur == 0) begin
                if_busy <= mem_read;
                mem_busy <= !mem_read;
                if_ready <= 0;
                mem_ready <= 0;
                cur <= cur+1;
            end else if (cur < tot) begin
                ret[cur-1] <= ram_r_data;
                cur <= cur+1;
            end else begin
                cur <= 0;
                if (mem_read) begin
                    mem_ready <= 1;
                    case (tot)
                        1: mem_data_o <= {{24{mem_signed && ram_r_data[7]}}, ram_r_data};
                        2: mem_data_o <= {{16{mem_signed && ram_r_data[7]}}, ram_r_data, ret[0]};
                        4: mem_data_o <= {ram_r_data, ret[2], ret[1], ret[0]};
                    endcase
                end else begin
                    if_ready <= 1;
                    if_data <= {ram_r_data, ret[2], ret[1], ret[0]};
                end
            end
        end else if (tot && ram_rw) begin
            if (cur == 0) begin
                if_busy <= 1;
                mem_busy <= 0;
                if_ready <= 0;
                mem_ready <= 0;
            end
            if (cur == tot-1) begin
                mem_ready <= 1;
                cur <= 0;
            end else begin
                cur <= cur+1;
            end
        end else begin
            if_busy <= 0;
            mem_busy <= 0;
            if_ready <= 0;
            mem_ready <= 0;
        end
    end

endmodule
