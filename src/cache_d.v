`include "define.v"

module cache_d(
    input wire clock,
    input wire reset,

    input wire ram_busy,
    input wire ram_ready,
    output reg ram_read,
    output reg [2:0] ram_length,
    output reg ram_signed,
    output reg [`MemAddrBus] ram_addr,
    input wire [`MemDataBus] ram_data,

    input wire buffer_busy,
    output reg buffer_write,
    output reg [2:0] buffer_length,
    output reg [`MemAddrBus] buffer_addr,
    output reg [`MemDataBus] buffer_data,

    input wire read,
    input wire write,
    output reg ready,
    input wire [2:0] length,
    input wire signed_,
    input wire [`MemAddrBus] addr,
    input wire [`MemDataBus] data_i,
    output reg [`MemDataBus] data_o
);

    reg [`DCacheNum-1:0] cache_valid, cache_dirty;
    reg [`DCacheTagBus] cache_tag [`DCacheNum-1:0];
    reg [`MemDataBus] cache_data [`DCacheNum-1:0];

    wire [`DCacheBus] addr_index = addr[`DCacheBus];
    wire [`DCacheTagBytes] addr_tag = addr[`DCacheTagBytes];
    wire [`ByteBus] cache_data_b_[3:0];
    assign cache_data_b_[0] = cache_data[addr_index][7:0];
    assign cache_data_b_[1] = cache_data[addr_index][15:8];
    assign cache_data_b_[2] = cache_data[addr_index][23:16];
    assign cache_data_b_[3] = cache_data[addr_index][31:24];
    wire [`ByteBus] cache_data_b = cache_data_b_[addr[1:0]];
    wire [15:0] cache_data_h_[1:0];
    assign cache_data_h_[0] = cache_data[addr_index][15:0];
    assign cache_data_h_[1] = cache_data[addr_index][31:16];
    wire [15:0] cache_data_h = cache_data_h_[addr[1]];
    wire [`MemDataBus] cache_data_w = cache_data[addr_index];

    wire [`MemAddrBus] flush_addr = {cache_tag[addr_index], addr_index, 2'b0};
    wire [`MemDataBus] flush_data = cache_data[addr_index];

    reg to_read, to_write, to_flush;
    reg cache_write;

    always @(*) begin
        ready = 0; data_o = 0;
        cache_write = 0;
        to_read = 0; to_write = 0; to_flush = 0;
        if (reset) begin
        end else if (read) begin
            if (!addr[17] && cache_valid[addr_index] && cache_tag[addr_index] == addr_tag) begin
                ready = 1;
                case (length)
                    1: data_o = {{24{cache_data_b[7] && signed_}}, cache_data_b};
                    2: data_o = {{16{cache_data_h[15] && signed_}}, cache_data_h};
                    4: data_o = cache_data_w;
                endcase
            end else if (length != 4) begin
                if (ram_ready) begin
                    ready = 1; data_o = ram_data;
                end else begin
                    to_read = 1;
                end
            end else begin
                if (ram_ready) begin
                    ready = 1; data_o = ram_data;
                end else if (!cache_dirty[addr_index]) begin
                    to_read = 1;
                end else if (!buffer_busy) begin
                    to_read = 1; to_flush = cache_valid[addr_index];
                end else if (buffer_addr == flush_addr && buffer_data == flush_data) begin
                    to_read = 1;
                end
            end
        end else if (write) begin
            if (!addr[17] && cache_valid[addr_index] && cache_tag[addr_index] == addr_tag) begin
                ready = 1; cache_write = 1;
            end else if (length != 4) begin
                if (!buffer_busy) begin
                    ready = 1; to_write = 1;
                end
            end else begin
                if (!cache_dirty[addr_index]) begin
                    ready = 1; cache_write = 1;
                end else if (!buffer_busy) begin
                    ready = 1; to_flush = cache_valid[addr_index]; cache_write = 1;
                end
            end
        end
    end

    reg delay_read;
    reg [2:0] history_length;

    always @(posedge clock) begin
        delay_read <= to_read;
        history_length <= ram_length;
        ram_length <= length;
        ram_addr <= addr;
        ram_signed <= signed_;
    end

    always @(*) begin
        ram_read = delay_read && !ram_busy;
    end

    always @(posedge clock) begin
        if (reset) begin
            buffer_write <= 0;
            buffer_length <= 0;
            buffer_addr <= 0;
            buffer_data <= 0;
        end else if (to_write || to_flush) begin
            buffer_write <= 1;
            buffer_length <= to_write ? length:to_flush ? 4:0;
            buffer_addr <= to_write ? addr:flush_addr;
            buffer_data <= to_write ? data_i:flush_data;
        end else begin
            buffer_write <= 0;
        end
    end

    reg [`MemDataBus] cache_write_data;

    always @(*) begin
        if (length == 1) begin
            case (addr[1:0])
                0: cache_write_data = {cache_data_h_[1], cache_data_b_[1], data_i};
                1: cache_write_data = {cache_data_h_[1], data_i, cache_data_b_[0]};
                2: cache_write_data = {cache_data_b_[3], data_i, cache_data_h_[0]};
                3: cache_write_data = {data_i, cache_data_b_[2], cache_data_h_[0]};
            endcase
        end else begin
            if (addr[1]) cache_write_data = {data_i, cache_data_h_[0]};
            else cache_write_data = {cache_data_h_[1], data_i};
        end
    end

    always @(posedge clock) begin
        if (reset) begin
            cache_valid <= 0;
            cache_dirty <= 0;
        end else if (cache_write) begin
            if (length != 4) begin
                cache_dirty[addr_index] <= 1;
                cache_data[addr_index] <= cache_write_data;
            end else begin
                cache_valid[addr_index] <= 1;
                cache_dirty[addr_index] <= 1;
                cache_tag[addr_index] <= addr_tag;
                cache_data[addr_index] <= data_i;
            end
        end else if (delay_read && ram_ready && history_length == 4) begin
            cache_valid[addr_index] <= 1;
            cache_dirty[addr_index] <= 0;
            cache_tag[addr_index] <= addr_tag;
            cache_data[addr_index] <= ram_data;
        end
    end

endmodule
