`include "define.v"

module cache_d(
    input wire clock,
    input wire reset,

    input wire ram_busy,
    input wire ram_ready,
    output reg ram_read,
    output reg ram_write,
    output reg [2:0] ram_length,
    output reg ram_signed,
    output reg [`MemAddrBus] ram_addr,
    input wire [`MemDataBus] ram_data_i,
    output reg [`MemDataBus] ram_data_o,

    input wire read,
    input wire write,
    input wire [2:0] length,
    input wire signed_,
    input wire [`MemAddrBus] addr,
    output reg ready,
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

    reg [1:0] todo;
    reg cache_write;

    always @(*) begin
        ready = 0;
        data_o = 0;
        cache_write = 0;
        todo = 0;
        if (reset) begin
        end else if (read) begin
            if (!addr[17] && cache_valid[addr_index] && cache_tag[addr_index] == addr_tag) begin
                ready = 1;
                case (length)
                    1: data_o = {{24{cache_data_b[7] && signed_}}, cache_data_b};
                    2: data_o = {{16{cache_data_h[15] && signed_}}, cache_data_h};
                    4: data_o = cache_data_w;
                endcase
            end else begin
                if (!addr[17] && length == 4 && cache_dirty[addr_index] && !ram_ready) begin
                    todo = 3;
                end else if (ram_read && ram_ready) begin
                    ready = 1; data_o = ram_data_i;
                end else begin
                    todo = 1;
                end
            end
        end else if (write) begin
            if (length != 4) begin
                if (!addr[17] && cache_valid[addr_index] && cache_tag[addr_index] == addr_tag) begin
                    ready = 1; cache_write = 1;
                end else if (ram_ready) begin
                    ready = 1;
                end else begin
                    todo = 2;
                end
            end else begin
                if (cache_dirty[addr_index] && cache_tag[addr_index] != addr_tag && !ram_ready) begin
                    todo = 3;
                end else begin
                    ready = 1; cache_write = 1;
                end
            end
        end else begin
            ready = 0; data_o = 0;
        end
    end

    wire [`MemAddrBus] delay_addr = todo == 3 ? {cache_tag[addr_index], addr_index, 2'b0}:addr;
    wire [2:0] delay_length = todo == 3 ? 4:length;
    wire delay_signed = signed_;
    wire [`MemDataBus] delay_data_o = todo == 3 ? cache_data_w:data_i;
    reg delay_read, delay_write;
    reg [2:0] history_length;

    always @(posedge clock) begin
        delay_read <= todo == 1;
        delay_write <= todo[1];
        history_length <= ram_length;
        ram_length <= delay_length;
        ram_addr <= delay_addr;
        ram_signed <= delay_signed;
        ram_data_o <= delay_data_o;
    end

    always @(*) begin
        ram_read = delay_read && !ram_busy;
        ram_write = delay_write && !ram_busy;
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
            cache_data[addr_index] <= ram_data_i;
        end else if (delay_write && ram_ready) begin
            if (history_length == 4) cache_dirty[addr_index] <= 0;
        end
    end

endmodule
