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

    output wire ram_rw,
    output reg [`MemAddrBus] ram_addr,
    output wire [`ByteBus] ram_w_data,
    input wire [`ByteBus] ram_r_data,

    output reg if_busy,
    output reg if_ready,
    output reg [`MemDataBus] if_data,

    output reg mem_busy,
    output reg mem_ready,
    output reg [`MemDataBus] mem_data_o
);

    reg [2:0] cur;
    reg [`ByteBus] ret [2:0];

    wire mem_read_working = mem_read && !mem_ready;
    wire if_working = !mem_read_working && if_read && !if_ready;
    wire mem_write_working = !if_working && mem_write && !mem_ready;
    wire mem_working = mem_read_working || mem_write_working;

    reg [2:0] tot;
    reg [`MemAddrBus] addr;

    wire [`ByteBus] write_data[3:0];
    assign write_data[0] = mem_data_i[7:0];
    assign write_data[1] = mem_data_i[15:8];
    assign write_data[2] = mem_data_i[23:16];
    assign write_data[3] = mem_data_i[31:24];

    assign ram_rw = mem_write_working;
    assign ram_w_data = write_data[cur];

    reg ahead, ahead_continue;
    reg [1:0] ahead_cur;
    reg [`MemAddrBus] ahead_addr;
    reg [`ByteBus] ahead_ret [2:0];

    always @(*) begin
        if (mem_working) begin
            addr = mem_addr;
            tot = mem_length;
        end else if (if_read) begin
            addr = if_addr;
            tot = 4;
        end else begin
            addr = ahead_addr;
            tot = 0;
        end
    end

    always @(*) begin
        if (mem_working) begin
            ram_addr = addr+cur;
            ahead_cur = 0;
        end else if (ahead) begin
            if (if_ready) begin
                ahead_cur = 0;
                ram_addr = ahead_addr+1;
            end else if (!if_read) begin
                ahead_cur = 1;
                ram_addr = ahead_addr+2;
            end else begin
                ahead_cur = 2;
                ram_addr = ahead_addr+3;
            end
        end else if (if_read) begin
            ram_addr = addr+cur;
            ahead_cur = 0;
        end else begin
            ram_addr = 0;
            ahead_cur = 0;
        end
    end

    always @(posedge clock) begin
        if (ahead) ret[ahead_cur] <= ram_r_data;
        if (reset || ((!if_read || if_discard) && !mem_working)) begin
            cur <= 0;
            if (ahead_continue) ahead_continue <= 0;
            else ahead <= 0;
            if_busy <= 0;
            if_ready <= 0;
            mem_busy <= 0;
            mem_ready <= 0;
        end else if (tot != 0 && !ram_rw) begin
            if (cur == 0) begin
                if_busy <= mem_read_working;
                mem_busy <= if_working;
                if_ready <= 0;
                mem_ready <= 0;
                ahead <= 0;
                if (if_read && ahead && ahead_addr == if_addr) begin
                    cur <= 4;
                end else begin
                    cur <= 1;
                end
            end else if (cur < tot) begin
                ret[cur-1] <= ram_r_data;
                cur <= cur+1;
            end else begin
                cur <= 0;
                if (if_working) begin
                    if_ready <= 1;
                    if_data <= {ram_r_data, ret[2], ret[1], ret[0]};
                    mem_busy <= 0;
                    ahead <= 1;
                    ahead_continue <= 1;
                    ahead_addr <= addr+4;
                end else begin
                    mem_ready <= 1;
                    case (tot)
                        1: mem_data_o <= {{24{mem_signed && ram_r_data[7]}}, ram_r_data};
                        2: mem_data_o <= {{16{mem_signed && ram_r_data[7]}}, ram_r_data, ret[0]};
                        4: mem_data_o <= {ram_r_data, ret[2], ret[1], ret[0]};
                    endcase
                    if_busy <= 0;
                end
            end
        end else if (tot != 0 && ram_rw) begin
            if (cur == 0) begin
                if_busy <= 1;
                mem_busy <= 0;
                if_ready <= 0;
                mem_ready <= 0;
                ahead <= 0;
            end
            if (cur == tot-1) begin
                mem_ready <= 1;
                cur <= 0;
                if_busy <= 0;
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
