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
        for (i = 0; i < 1024; i = i + 1) ram[i] = 0;
        // ram[3] = 8'b0000_0000; ram[2] = 8'b0000_0000; ram[1] = 8'b1111_0000; ram[0] = 8'b1_0110111; // LUI
        // ram[3] = 8'b1011_1111; ram[2] = 8'b0110_0100; ram[1] <= 8'b0111_0001; ram[0] <= 8'b0_0110111; // LUI
        ram[3] = 8'b00000110; ram[2] = 8'b0100_0000; ram[1] = 8'b0_010_0000; ram[0] = 8'b1_0000011; // LW
        // ram[7] = 8'b1_1111111; ram[6] = 8'b110_1_1111; ram[5] = 8'b1111_0000; ram[4] = 8'b1_1101111; // JAL
        ram[7] = 8'b00000110; ram[6] = 8'b0100_0000; ram[5] = 8'b0_010_0001; ram[4] = 8'b0_0000011; // LW
        // ram[11] = 8'b0000001_0; ram[10] = 8'b0001_0000; ram[9] = 8'b0_010_1010; ram[8] = 8'b0_0100011; // SW
        ram[11] = 8'b1_111111_0; ram[10] = 8'b0010_0000; ram[9] = 8'b1_000_1100; ram[8] = 8'b1_1100011; // BEQ
        ram[103] = 8'b01010101; ram[102] = 8'b11111111; ram[101] = 8'b11011011; ram[100] = 8'b01100110;
    end

    always @(posedge clock) begin
        if (rw) begin
            ram[addr] <= write;
        end
    end

endmodule
