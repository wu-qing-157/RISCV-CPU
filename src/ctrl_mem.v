`include "define.v"

module ctrl_mem(
    input wire clock,
    input wire reset,

    input wire if_read,
    input wire [`MemAddrBus] if_addr_i,

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

    output reg busy,

    output reg if_ready,
    output reg [`MemDataBus] if_data_o,
    output reg [`MemAddrBus] if_addr_o,

    output reg mem_ready,
    output reg [`MemDataBus] mem_data_o
);

    reg [2:0] cur, tot;
    reg [1:0] status;
    reg [`MemAddrBus] addr;
    reg [`MemDataBus] data;
    wire [`ByteBus] write_data[3:0];
    reg [`ByteBus] ret [3:0];
    wire [`MemDataBus] data_o;

    assign write_data[0] = data[7:0];
    assign write_data[1] = data[15:8];
    assign write_data[2] = data[23:16];
    assign write_data[3] = data[31:24];
    assign data_o = {ret[3], ret[2], ret[1], ret[0]};

    always @(posedge clock) begin
        if_ready <= 0;
        mem_ready <= 0;
        if (reset) begin
            busy <= 0;
            if_data_o <= 0;
            mem_data_o <= 0;
        end else begin
            if (status == 0) begin
                if (mem_write) begin
                    busy <= 1; cur <= 0; tot <= mem_length; status = 3;
                    addr <= mem_data_i;
                end else if (if_read) begin
                    busy <= 1; cur <= 0; tot <= 4; status = 1; addr <= if_addr_i;
                end else if (mem_read) begin
                    busy <= 1; cur <= 0; tot <= mem_length; status = 2; addr <= mem_addr;
                end else begin
                    busy <= 0; cur <= 0; tot <= 0; ram_rw <= 0; ram_addr <= 0;
                end
            end
            if (status != 0) begin
                if (cur > 0 && status != 3) begin
                    ret[cur-1] <= ram_r_data;
                end
                if (cur < tot) begin
                    ram_addr <= addr+cur;
                    if (status == 3) begin
                        ram_rw <= 1;
                        ram_w_data <= write_data[cur];
                    end else begin
                        ram_rw <= 0;
                    end
                end else begin
                    case (status)
                        1: begin
                            if_ready <= 1;
                            if_addr_o <= addr;
                            if_data_o <= data_o;
                        end
                        2: begin
                            case (tot)
                                1: begin
                                    ret[1] = {8{mem_signed & ret[0][7]}};
                                    ret[2] = {8{mem_signed & ret[0][7]}};
                                    ret[3] = {8{mem_signed & ret[0][7]}};
                                end
                                2: begin
                                    ret[3] = {8{mem_signed & ret[2][7]}};
                                end
                            endcase
                            mem_ready <= 1;
                            mem_data_o <= data_o;
                        end
                    endcase
                end
            end
        end
    end

endmodule: ctrl_mem
