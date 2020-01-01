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
    wire [`MemDataBus] addr_data = cache_data[addr_index];

    wire buffer_miss = !buffer_busy || addr[`DCacheAllBytes] != buffer_addr[`DCacheAllBytes];

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
                if (length[0]) begin
                    case (addr[1:0])
                        0: data_o = {{24{signed_ && addr_data[7]}}, addr_data[7:0]};
                        1: data_o = {{24{signed_ && addr_data[15]}}, addr_data[15:8]};
                        2: data_o = {{24{signed_ && addr_data[23]}}, addr_data[23:16]};
                        default: data_o = {{24{signed_ && addr_data[31]}}, addr_data[31:24]};
                    endcase
                end else if (length[1]) begin
                    if (addr[1]) data_o = {{16{signed_ && addr_data[15]}}, addr_data[15:0]};
                    else data_o = {{16{signed_ && addr_data[31]}}, addr_data[31:16]};
                end else begin
                    data_o = addr_data;
                end
            end else if (!length[2]) begin
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
                end else if (buffer_addr[`DCacheAllBytes] == {cache_tag[addr_index], addr_index}/* && buffer_data == addr_data*/) begin
                    to_read = 1;
                end
            end
        end else if (write) begin
            if (!addr[17] && cache_valid[addr_index] && cache_tag[addr_index] == addr_tag) begin
                ready = 1; cache_write = 1;
            end else if (!length[2]) begin
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

    reg delay_read, update_cache;

    always @(posedge clock) begin
        delay_read <= to_read && buffer_miss;
        update_cache <= ram_length[2];
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
            buffer_addr <= to_write ? addr:{cache_tag[addr_index], addr_index, 2'b0};
            buffer_data <= to_write ? data_i:addr_data;
        end else begin
            buffer_write <= 0;
        end
    end

    always @(posedge clock) begin
        if (reset) begin
            cache_valid <= 0;
            cache_dirty <= 0;
        end else if (cache_write) begin
            cache_dirty[addr_index] <= 1;
            if (length[0]) begin
                case (addr[1:0])
                    0: cache_data[addr_index][7:0] <= data_i;
                    1: cache_data[addr_index][15:8] <= data_i;
                    2: cache_data[addr_index][23:16] <= data_i;
                    3: cache_data[addr_index][31:24] <= data_i;
                endcase
            end else if (length[1]) begin
                if (addr[1]) cache_data[addr_index][31:16] <= data_i;
                else cache_data[addr_index][15:0] <= data_i;
            end else begin
                cache_valid[addr_index] <= 1;
                cache_tag[addr_index] <= addr_tag;
                cache_data[addr_index] <= data_i;
            end
        end else if (delay_read && ram_ready && update_cache) begin
            cache_valid[addr_index] <= 1;
            cache_dirty[addr_index] <= 0;
            cache_tag[addr_index] <= addr_tag;
            cache_data[addr_index] <= ram_data;
        end
    end

endmodule
