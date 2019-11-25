module fake_mem(
    input wire clock,
    input wire rw,
    input wire [7:0] write,
    output wire [7:0] read,
    input wire [31:0] addr
);

    reg [7:0] ram [1023:0];
    reg [31:0] i;

    assign read = ram[addr];

    initial begin
        ram[3] <= 8'b0000_0000; ram[2] <= 8'b0000_0000; ram[1] <= 8'b1111_0000; ram[0] <= 8'b1_0110111;
        // ram[7] <= 8'b1111_1111; ram[6] <= 8'b1111_0000; ram[5] <= 8'b0000_0001; ram[4] <= 8'b0_0110111;
        ram[7] <= 8'b1_1111111; ram[6] <= 8'b110_1_1111; ram[5] <= 8'b1111_0000; ram[4] <= 8'b1_1101111;
        for (i = 8; i < 1024; i = i + 1) ram[i] <= 0;
    end

    always @(posedge clock) begin
        if (rw) begin
            ram[addr] <= write;
        end
    end

endmodule
