`ifndef DEFINE_V
`define DEFINE_V

`define OP_LUI      7'b0110111
`define OP_AUIPC    7'b0010111
`define OP_JAL      7'b1101111
`define OP_JALR     7'b1100111
`define OP_BRANCH   7'b1100011
`define OP_LOAD     7'b0000011
`define OP_STORE    7'b0100011
`define OP_OP_IMM   7'b0010011
`define OP_OP       7'b0110011
`define OP_MISC_MEM 7'b0001111

// BRANCH
`define FUNCT3_BEQ  3'b000
`define FUNCT3_BNE  3'b001
`define FUNCT3_BLT  3'b100
`define FUNCT3_BGE  3'b101
`define FUNCT3_BLTU 3'b110
`define FUNCT3_BGEU 3'b111
// LOAD
`define FUNCT3_LB   3'b000
`define FUNCT3_LH   3'b001
`define FUNCT3_LW   3'b010
`define FUNCT3_LBU  3'b100
`define FUNCT3_LHU  3'b101
// STORE
`define FUNCT3_SB   3'b000
`define FUNCT3_SH   3'b001
`define FUNCT3_SW   3'b010
// OP_IMM
`define FUNCT3_ADDI     3'b000
`define FUNCT3_SLLI     3'b001
`define FUNCT3_SLTI     3'b010
`define FUNCT3_SLTIU    3'b011
`define FUNCT3_XORI     3'b100
`define FUNCT3_SRI      3'b101
`define FUNCT3_ORI      3'b110
`define FUNCT3_ANDI     3'b111
// OP
`define FUNCT3_ADD_SUB  3'b000
`define FUNCT3_SLL      3'b001
`define FUNCT3_SLT      3'b010
`define FUNCT3_SLTU     3'b011
`define FUNCT3_XOR      3'b100
`define FUNCT3_SR       3'b101
`define FUNCT3_OR       3'b110
`define FUNCT3_AND      3'b111
// MISC_MEM
`define FUNCT3_FENCE    3'b000
`define FUNCT3_FENCEI   3'b001

// SRI
`define FUNCT3_SRLI 7'b0000000
`define FUNCT3_SHAI 7'b0100000
// ADD_SUB
`define FUNCT3_ADD  7'b0000000
`define FUNCT3_SUB  7'b0100000
// SR
`define FUNCT3_SRL  7'b0000000
`define FUNCT3_SHA  7'b0100000

`define EXE_RES_NOP         3'b000
`define EXE_RES_LOGIC       3'b001
`define EXE_RES_SHIFT       3'b010
`define EXE_RES_MOVE        3'b011
`define EXE_RES_ARITH       3'b100
`define EXE_RES_MUL         3'b101
`define EXE_RES_JUMP_BRANCH 3'b110
`define EXE_RES_LOAD_STORE  3'b111

`define EXE_OP_NOP  0
`define EXE_OP_AND  1
`define EXE_OP_OR   2
`define EXE_OP_XOR  3
`define EXE_OP_SLL  4
`define EXE_OP_SRL  5
`define EXE_OP_SRA  6
`define EXE_OP_ADD  7
`define EXE_OP_SUB  8
`define EXE_OP_SLT  9
`define EXE_OP_SLTU 10
`define EXE_OP_JAL  11
`define EXE_OP_JALR 12
`define EXE_OP_BEQ  13
`define EXE_OP_BNE  14
`define EXE_OP_BLT  15
`define EXE_OP_BGE  16
`define EXE_OP_BLTU 17
`define EXE_OP_BGEU 18
`define EXE_OP_LB   19
`define EXE_OP_LH   20
`define EXE_OP_LW   21
`define EXE_OP_LBU  22
`define EXE_OP_LHU  23
`define EXE_OP_SB   24
`define EXE_OP_SH   25
`define EXE_OP_SW   26

`define InstBus         31:0
`define InstMemNum      131072
`define InstMemNumLog2  17

`define RegAddrBus  4:0
`define RegBus      31:0
`define RegNum      32
`define RegNumLog2  5

`define AluOpBus    4:0
`define AluSelBus   2:0

`define MemAddrBus      31:0
`define MemAddrWidth    32
`define MemDataBus      31:0
`define MemDataWidth    32
`define ByteBus         7:0
`define DataMemNum      131072
`define DataMemNumLog2  17
`define ICacheBus       9:2
`define ICacheNum       256
`define ICacheNumLog2   8
`define ICacheTagBytes  16:10
`define ICacheTagBus    6:0
`define DCacheBus       8:2
`define DCacheNum       128
`define DCacheNumLog2   7
`define DCacheTagBytes  16:9
`define DCacheTagBus    7:0
`define DCacheAllBytes  31:2
`define BTBBus          6:2
`define BTBNum          32
`define BTBNumLog2      5
`define BTBTagBytes     16:7
`define BTBTagBus       9:0
`define BTBAllBytes     16:2

`define StallBus        5:0

`endif // DEFINE_V
