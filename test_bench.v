`timescale 1ns/1ps

`include "sopc.v"

module test_bunch;

    reg clock50;
    reg reset;

    initial begin
        clock50 = 0;
        forever #10 clock50 = ~clock50;
    end

    initial begin
        reset = 1;
        #195 reset = 0;
        #1000 $finish;
    end

    sopc sopc0(
        .clock(clock50), .reset(reset)
    );

endmodule