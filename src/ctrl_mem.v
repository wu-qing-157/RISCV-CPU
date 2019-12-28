`include "define.v"

module ctrl_mem(
    input wire clock,
    input wire reset,
    input wire if_discard,

    input wire if_read,
    input wire [`MemAddrBus] if_addr,

    input wire mem_read,
    input wire mem_write,
    input wire [`MemAddrBus] mem_addr,
    input wire [`MemDataBus] mem_data_i,
    input wire [2:0] mem_length,
    input wire mem_signed,

    output reg ram_rw,
    output reg [`MemAddrBus] ram_addr,
    output reg [`ByteBus] ram_w_data,
    input wire [`ByteBus] ram_r_data,

    output reg if_busy,
    output reg if_ready,
    output reg [`MemDataBus] if_data,

    output reg mem_busy,
    output reg mem_ready,
    output reg [`MemDataBus] mem_data_o
);

    reg [2:0] cur, tot;
    reg [`ByteBus] ret [2:0];

    wire [`ByteBus] write_data[3:1];
    assign write_data[1] = mem_data_i[15:8];
    assign write_data[2] = mem_data_i[23:16];
    assign write_data[3] = mem_data_i[31:24];

    always @(posedge clock) begin
        if (reset || (if_discard && !(mem_read || mem_write))) begin
            cur <= 0;
            tot <= 0;
            if_busy <= 0;
            if_ready <= 0;
            mem_busy <= 0;
            mem_ready <= 0;
            ram_rw <= 0;
            ram_addr <= 0;
        end else if (tot == 0) begin
            if (mem_read) begin
                if_busy <= 1;
                if_ready <= 0;
                mem_ready <= 0;
                cur <= 0;
                tot <= mem_length;
                ram_rw <= 0;
                ram_addr <= mem_addr;
            end else if (mem_write) begin
                if_busy <= 1;
                if_ready <= 0;
                mem_ready <= 0;
                ram_rw <= 1;
                tot <= mem_length;
                cur <= 1;
                ram_addr <= mem_addr;
                ram_w_data <= mem_data_i[7:0];
            end else if (if_read) begin
                mem_busy <= 1;
                if_ready <= 0;
                mem_ready <= 0;
                cur <= 0;
                tot <= 4;
                ram_rw <= 0;
                ram_addr <= if_addr;
            end else begin
                if_ready <= 0;
                mem_ready <= 0;
                ram_rw <= 0;
                ram_addr <= 0;
            end
        end else if (cur == tot) begin
            cur <= 0;
            tot <= 0;
            if (mem_read) begin
                if_busy <= 0;
                mem_ready <= 1;
                case (mem_length)
                    1: mem_data_o <= {{24{ram_r_data[7] && mem_signed}}, ram_r_data};
                    2: mem_data_o <= {{16{ram_r_data[7] && mem_signed}}, ram_r_data, ret[0]};
                    4: mem_data_o <= {ram_r_data, ret[2], ret[1], ret[0]};
                endcase
            end else if (mem_write) begin
                if_busy <= 0;
                mem_ready <= 1;
                ram_rw <= 0;
            end else if (if_read) begin
                mem_busy <= 0;
                if_ready <= 1;
                if_data <= {ram_r_data, ret[2], ret[1], ret[0]};
            end
        end else begin
            if (mem_read || if_read) begin
                ram_addr <= (mem_read ? mem_addr:if_addr)+cur+1;
                if (cur > 0)
                    ret[cur-1] <= ram_r_data;
            end else if (mem_write) begin
                ram_addr <= mem_addr+cur;
                ram_w_data <= write_data[cur];
            end
            cur <= cur+1;
        end
    end

endmodule
