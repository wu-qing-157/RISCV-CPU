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

    output wire busy,

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
    reg [`ByteBus] ret [2:0];
    reg signed_;

    assign busy = cur < tot;

    initial begin
        cur <= 0;
        tot <= 0;
        status <= 0;
        addr <= 0;
        ram_rw <= 0;
        ram_addr <= 0;
    end

    always @(posedge clock) begin
        if (reset) begin
            cur <= 0;
            tot <= 0;
            if_data_o <= 0;
            mem_data_o <= 0;
            ram_rw <= 0;
            ram_addr <= 0;
        end else begin
            if (cur == tot) begin
                if (mem_write) begin
                    cur <= 1; tot <= mem_length; status <= 3;
                    addr <= mem_addr; data <= mem_data_i;
                    ram_rw <= 1; ram_addr <= mem_addr; ram_w_data <= mem_data_i[7:0];
                end else if (if_read) begin
                    if_ready <= 0; cur <= 0; tot <= 4; status <= 1;
                    addr <= if_addr_i;
                    ram_rw <= 0; ram_addr <= if_addr_i;
                end else if (mem_read) begin
                    mem_ready <= 0; cur <= 0; tot <= mem_length; status <= 2;
                    addr <= mem_addr;
                    ram_rw <= 0; ram_addr <= mem_addr;
                    signed_ <= mem_signed;
                end
            end else if (status == 3) begin
                case (cur)
                    1: begin
                        ram_addr <= addr+1; ram_w_data <= data[15:8];
                    end
                    2: begin
                        ram_addr <= addr+2; ram_w_data <= data[23:16];
                    end
                    3: begin
                        ram_addr <= addr+3; ram_w_data <= data[31:24];
                    end
                endcase
                cur <= cur+1;
            end else begin
                if (cur == tot-1) begin
                    if (status == 1) begin
                        if_ready <= 1; if_addr_o <= addr;
                        if_data_o <= {ram_r_data, ret[2], ret[1], ret[0]};
                    end else begin
                        mem_ready <= 1;
                        case (tot)
                            1: mem_data_o <= {{24{ram_r_data[7]}}, ram_r_data};
                            2: mem_data_o <= {{16{ram_r_data[7]}}, ram_r_data, ret[0]};
                            4: mem_data_o <= {ram_r_data, ret[2], ret[1], ret[0]};
                        endcase
                    end
                end else begin
                    ret[cur] <= ram_r_data;
                    ram_addr <= addr+cur+1;
                end
                cur <= cur+1;
            end
        end
    end

endmodule
