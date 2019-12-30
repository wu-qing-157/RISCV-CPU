`include "define.v"

module ctrl_mem(
    input wire clock,
    input wire reset,
    input wire if_discard,

    input wire if_read,
    input wire [`MemAddrBus] if_addr,
    output reg if_busy,
    output reg if_ready,
    output reg [`MemDataBus] if_data,

    input wire mem_read,
    input wire [`MemAddrBus] mem_r_addr,
    input wire [2:0] mem_r_length,
    input wire mem_r_signed,
    output reg mem_r_busy,
    output reg mem_r_ready,
    output reg [`MemDataBus] mem_r_data,

    input wire mem_write,
    input wire [`MemAddrBus] mem_w_addr,
    input wire [`ByteBus] mem_w_data,
    output reg mem_w_busy,
    output wire mem_w_success,

    output wire ram_rw,
    output reg [`MemAddrBus] ram_addr,
    output wire [`ByteBus] ram_w_data,
    input wire [`ByteBus] ram_r_data
);

    reg [2:0] cur;
    reg [`ByteBus] ret [2:0];

    wire mem_read_working = mem_read && !mem_r_ready;
    wire if_working = !mem_read_working && if_read && !if_ready;
    wire mem_write_working = !mem_read_working && !if_read && mem_write;
    wire mem_working = mem_read_working || mem_write_working;
    assign mem_w_success = mem_write_working;

    reg [2:0] tot;
    reg [`MemAddrBus] addr;

    assign ram_rw = mem_write_working;
    assign ram_w_data = mem_w_data;

    reg ahead;
    reg [1:0] ahead_cur;
    reg [`MemAddrBus] ahead_addr;
    reg [`ByteBus] ahead_ret [2:0];

    always @(*) begin
        if (mem_read_working) begin
            addr = mem_r_addr;
            tot = mem_r_length;
        end else if (if_working) begin
            addr = if_addr;
            tot = 4;
        end else if (mem_write_working) begin
            addr = mem_w_addr;
            tot = 1;
        end else begin
            addr = ahead_addr;
            tot = 0;
        end
    end

    always @(*) begin
        if (mem_working || (if_working && !(ahead && ahead_addr == if_addr))) begin
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
        end else begin
            ram_addr = 0;
            ahead_cur = 0;
        end
    end

    always @(posedge clock) begin
        if (ahead) ret[ahead_cur] <= ram_r_data;
        if (if_discard || mem_working) ahead <= 0;
        if (reset) begin
            cur <= 0;
            if_ready <= 0;
            mem_r_ready <= 0;
            if_busy <= 0;
            mem_r_busy <= 0;
            mem_w_busy <= 0;
        end else if (mem_read_working) begin
            if (cur == 0) begin
                if_ready <= 0;
                mem_r_ready <= 0;
                if_busy <= 1;
                mem_r_busy <= 0;
                mem_w_busy <= 1;
                ahead <= 0;
                cur <= 1;
            end else if (cur < tot) begin
                ret[cur-1] <= ram_r_data;
                cur <= cur+1;
            end else begin
                cur <= 0;
                mem_r_ready <= 1;
                case (tot)
                    1: mem_r_data <= {{24{mem_r_signed && ram_r_data[7]}}, ram_r_data};
                    2: mem_r_data <= {{16{mem_r_signed && ram_r_data[7]}}, ram_r_data, ret[0]};
                    4: mem_r_data <= {ram_r_data, ret[2], ret[1], ret[0]};
                endcase
                if_busy <= 0;
                mem_w_busy <= 0;
            end
        end else if (if_working) begin
            if (if_discard) begin
                cur <= 0;
                if_ready <= 0;
                mem_r_ready <= 0;
                if_busy <= 0;
                mem_r_busy <= 0;
                mem_w_busy <= 0;
            end else if (cur == 0) begin
                if_ready <= 0;
                mem_r_ready <= 0;
                if_busy <= 0;
                mem_r_busy <= 1;
                mem_w_busy <= 1;
                ahead <= 0;
                if (ahead && ahead_addr == if_addr) begin
                    cur <= 4;
                end else begin
                    cur <= 1;
                end
            end else if (cur < tot) begin
                ret[cur-1] <= ram_r_data;
                cur <= cur+1;
            end else begin
                cur <= 0;
                if_ready <= 1;
                if_data <= {ram_r_data, ret[2], ret[1], ret[0]};
                ahead <= 1;
                ahead_addr <= addr+4;
                mem_r_busy <= 0;
                mem_w_busy <= 0;
            end
        end else if (mem_write_working) begin
            if_ready <= 0;
            mem_r_ready <= 0;
            if_busy <= 0;
            mem_r_busy <= 0;
            mem_w_busy <= 0;
            ahead <= 0;
        end else begin
            if_ready <= 0;
            mem_r_ready <= 0;
        end
    end

endmodule
