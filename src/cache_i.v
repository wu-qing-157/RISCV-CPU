`include "define.v"

module cache_i(
    input wire reset,

    input wire ram_busy,
    input wire ram_ready,
    input wire [`MemDataBus] ram_data,
    output reg ram_read,
    output reg [`MemAddrBus] ram_addr,

    input wire read,
    input wire [`MemAddrBus] addr,
    output reg ready,
    output reg [`MemDataBus] data
);

    reg [`MemDataBus] cache_data [`ICacheNum-1:0];
    reg [`ICacheTagBus] cache_tag [`ICacheNum-1:0];

    reg [31:0] i;

    initial begin
        ram_read = 0;
        for (i = 0; i < `ICacheNum; i = i+1)
            cache_tag[i] = -1;
    end

    always @(*) begin
        if (reset || !read) begin
            ready = 0; data = 0;
            ram_read = 0; ram_addr = 0;
        end else begin
            if (cache_tag[addr[`ICacheBus]] == addr[`ICacheTagBytes]) begin
                ready = 1; data = cache_data[addr[`ICacheBus]];
                ram_read = 0; ram_addr = 0;
            end else begin
                ready = 0; data = 0;
                if (!ram_busy) begin
                    ram_read = 1;
                    ram_addr = addr;
                end else begin
                    ram_read = 0; ram_addr = 0;
                end
            end
        end
    end

    always @(*) begin
        if (ram_ready) begin
            cache_tag[addr[`ICacheBus]] = addr[`ICacheTagBytes];
            cache_data[addr[`ICacheBus]] = ram_data;
        end
    end

endmodule
