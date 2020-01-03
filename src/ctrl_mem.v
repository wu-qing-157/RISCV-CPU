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
    reg [`ByteBus] if_ret [3:0], mem_ret [2:0];

    reg ahead, ahead_ready;
    reg [2:0] ahead_cur;
    reg [`MemAddrBus] ahead_addr;
    wire [`MemAddrBus] delay_ahead_addr = if_addr+4;

    wire mem_read_working = mem_read && !mem_r_ready;
    wire if_working = if_read && !if_ready;
    wire ahead_working = ahead && !ahead_ready;
    wire mem_write_working = mem_write;
    assign mem_w_success = !mem_read_working && !if_working && !ahead_working && mem_write_working;

    assign ram_rw = mem_w_success;
    assign ram_w_data = mem_w_data;

    always @(*) begin
        if (mem_read_working) begin
            ram_addr = (ahead && mem_r_length == cur) ? ahead_addr+ahead_cur:mem_r_addr+cur;
        end else if (if_working) begin
            ram_addr = ahead && ahead_addr == if_addr ? ahead_addr+ahead_cur:if_addr+cur;
        end else if (ahead_working) begin
            ram_addr = ahead_addr+ahead_cur;
        end else if (mem_write_working) begin
            ram_addr = mem_w_addr;
        end else begin
            ram_addr = 0;
        end
    end

    always @(posedge clock) begin
        if (reset) begin
            if_ready <= 0; mem_r_ready <= 0;
            if_busy <= 0; mem_r_busy <= 0; mem_w_busy <= 0;
            ahead <= 0; cur <= 0; ahead_cur <= 0;
        end else if (mem_read_working) begin
            if (cur == 0) begin
                if_ready <= 0; mem_r_ready <= 0;
                if_busy <= 1; mem_r_busy <= 0; mem_w_busy <= 1;
                cur <= 1;
                if (mem_r_addr[17]) ahead <= 0;
                else if (!ahead_ready) if_ret[ahead_cur-1] <= ram_r_data;
            end else if (cur < mem_r_length) begin
                mem_ret[cur-1] <= ram_r_data;
                cur <= cur+1;
            end else begin
                mem_r_ready <= 1;
                if_busy <= 0; mem_w_busy <= 0;
                cur <= 0;
                case (mem_r_length)
                    1: mem_r_data <= {{24{mem_r_signed && ram_r_data[7]}}, ram_r_data};
                    2: mem_r_data <= {{16{mem_r_signed && ram_r_data[7]}}, ram_r_data, mem_ret[0]};
                    4: mem_r_data <= {ram_r_data, mem_ret[2], mem_ret[1], mem_ret[0]};
                endcase
                if (ahead && !ahead_ready) begin
                    if (ahead_cur[2]) ahead_ready <= 1;
                    else ahead_cur <= ahead_cur+1;
                end
            end
        end else if (if_working) begin
            if (if_discard) begin
                if_ready <= 0; mem_r_ready <= 0;
                if_busy <= 0; mem_r_busy <= 0; mem_w_busy <= 0;
                ahead <= 0; cur <= 0;
            end else if (cur == 0) begin
                if (!ahead || ahead_addr != if_addr) begin
                    if_ready <= 0; mem_r_ready <= 0;
                    if_busy <= 0; mem_r_busy <= 1; mem_w_busy <= 1;
                    cur <= 1;
                end else if (ahead_ready) begin
                    if_ready <= 1; mem_r_ready <= 0;
                    if_busy <= 0; mem_r_busy <= 0; mem_w_busy <= 0;
                    cur <= 0;
                    if_data <= {if_ret[3], if_ret[2], if_ret[1], if_ret[0]};
                    ahead_addr <= delay_ahead_addr; ahead_cur <= 1; ahead_ready <= 0;
                end else if (ahead_cur[2]) begin
                    if_ready <= 1; mem_r_ready <= 0;
                    if_busy <= 0; mem_r_busy <= 0; mem_w_busy <= 0;
                    cur <= 0;
                    if_data <= {ram_r_data, if_ret[2], if_ret[1], if_ret[0]};
                    ahead_addr <= delay_ahead_addr; ahead_cur <= 1; ahead_ready <= 0;
                end else begin
                    if_ready <= 0; mem_r_ready <= 0;
                    if_busy <= 0; mem_r_busy <= 1; mem_w_busy <= 1;
                    if_ret[ahead_cur-1] <= ram_r_data;
                    cur <= ahead_cur+1;
                    ahead <= 0;
                end
            end else if (!cur[2]) begin
                if_ret[cur-1] <= ram_r_data;
                cur <= cur+1;
            end else begin
                if_ready <= 1;
                mem_r_busy <= 0; mem_w_busy <= 0;
                cur <= 0;
                if_data <= {ram_r_data, if_ret[2], if_ret[1], if_ret[0]};
                ahead <= 1; ahead_addr <= delay_ahead_addr; ahead_cur <= 1; ahead_ready <= 0;
            end
        end else if (ahead_working) begin
            if (if_discard) begin
                if_ready <= 0; mem_r_ready <= 0;
                ahead <= 0; cur <= 0; ahead_cur <= 0;
            end else begin
                if_ready <= 0; mem_r_ready <= 0;
                if_ret[ahead_cur-1] <= ram_r_data;
                if (ahead_cur[2]) ahead_ready <= 1;
                else ahead_cur <= ahead_cur+1;
            end
        end else begin
            if_ready <= 0; mem_r_ready <= 0;
        end
    end

endmodule
