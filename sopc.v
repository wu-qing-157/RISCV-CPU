`include "mips.v"
`include "rom.v"

module sopc(
    input wire clock,
    input wire reset
);

    wire ce;
    wire[`InstructionAddressBus] pc;
    wire[`InstructionBus] instruction;

    mips mips0(
        .clock(clock), .reset(reset),
        .rom_ce(ce), .rom_address(pc), .rom_data(instruction)
    );

    rom rom0(
        .ce(ce), .pc(pc), .instruction(instruction)
    );

endmodule