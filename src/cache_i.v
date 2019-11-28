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
        for (i = 0; i < `ICacheNum; i = i+1) begin
            cache_tag[i] = -1;
            //$display("%h %h", i, cache_tag[i]);
        end
        //$display("%h", cache_tag[7'h3c]);
    end

    always @(*) begin
        if (reset) begin
            ready = 0;
        end else begin
            if (cache_tag[addr[`ICacheBus]] == addr[`ICacheTagBytes]) begin
                //$display("%h cache hit!", addr);
                ready = 1; data = cache_data[addr[`ICacheBus]];
                ram_read = 0;
            end else begin
                //$display("%h cache miss! ram_ready %h read %h", addr, ram_ready, read);
                //$display("bus %h tag %h stored_tag %h", addr[`ICacheBus], addr[`ICacheTagBytes], cache_tag[addr[`ICacheBus]]);
                if (read) begin
                    if (ram_ready) begin
                        cache_data[addr[`ICacheBus]] = ram_data;
                        //$display("store tag");
                        cache_tag[addr[`ICacheBus]] = addr[`ICacheTagBytes];
                        ram_read = 0;
                        ready = 1;
                        data = ram_data;
                    end else begin
                        if (!ram_busy) begin
                            ram_read = 1;
                            ram_addr = addr;
                        end else begin
                            ram_read = 0;
                        end
                    end
                end else begin
                    ready = 0;
                end
            end
        end
    end

endmodule
