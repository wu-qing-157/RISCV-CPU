`include "define.v"
`include "fake_mem.v"
`include "cpu.v"

module test2;

    reg clock50;
    reg reset;

    initial begin
        clock50 = 0;
        forever #10 clock50 = ~clock50;
    end

    initial begin
        reset = 1;
        #30 reset = 0;
        #2000 $finish();
    end

    wire rw;
    wire [7:0] read, write;
    wire [31:0] addr;

    fake_mem fake_mem_(
        .clock(clock50), .rw(rw), .read(read), .write(write), .addr(addr)
    );

    cpu cpu_(
        .clk_in(clock50), .rst_in(reset),
        .mem_din(read), .mem_dout(write), .mem_a(addr), .mem_wr(rw)
    );

endmodule
