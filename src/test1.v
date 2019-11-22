// Test ori
// Using fake_mem_if as memory access during IF

`include "cpu.v"

module test1;

    reg clock50;
    reg reset;

    initial begin
        clock50 = 0;
        forever #10 clock50 = ~clock50;
    end

    initial begin
        reset = 1;
        #30 reset = 0;
        #20000 $finish();
    end

    cpu cpu_(
        .clk_in(clock50), .rst_in(reset)
    );

endmodule
