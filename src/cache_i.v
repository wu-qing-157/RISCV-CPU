`include "define.v"

module cache_i(
    input wire clock,
    input wire reset,

    input wire ram_busy,
    input wire ram_ready,
    input wire [`MemDataBus] ram_data,
    output reg ram_read,
    output wire [`MemAddrBus] ram_addr,

    input wire read,
    input wire [`MemAddrBus] addr,
    output reg ready,
    output reg [`MemDataBus] data
);

    assign ram_addr = addr;

    reg cache_valid [`ICacheNum-1:0];
    reg [`ICacheTagBus] cache_tag [`ICacheNum-1:0];
    reg [`MemDataBus] cache_data [`ICacheNum-1:0];

    wire [`ICacheBus] addr_index = addr[`ICacheBus];
    wire [`ICacheTagBytes] addr_tag = addr[`ICacheTagBytes];

    reg [31:0] i;

    initial begin
        for (i = 0; i < `ICacheNum; i = i+1) cache_valid[i] = 0;
    end

    always @(*) begin
        if (reset || !read) begin
            ready = 0; data = 0; ram_read = 0;
        end else begin
            if (cache_valid[addr_index] && cache_tag[addr_index] == addr_tag) begin
                ready = 1; data = cache_data[addr_index]; ram_read = 0;
            end else if (ram_ready) begin
                ready = 1; data = ram_data; ram_read = 0;
            end else if (!ram_busy) begin
                ready = 0; data = 0; ram_read = 1;
            end else begin
                ready = 0; data = 0; ram_read = 0;
            end
        end
    end

    always @(posedge clock) begin
        if (ram_ready) begin
            cache_valid[addr_index] <= 1;
            cache_tag[addr_index] <= addr_tag;
            cache_data[addr_index] <= ram_data;
        end
    end

endmodule
