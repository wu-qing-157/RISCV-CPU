`include "define.v"

module stage_id(
    input wire reset,

    input wire [`MemAddrBus] pc,
    input wire [`InstBus] inst,

    output reg read1,
    output reg [`RegAddrBus] reg1_addr,
    input wire [`RegBus] reg1_data,
    output reg read2,
    output reg [`RegAddrBus] reg2_addr,
    input wire [`RegBus] reg2_data,

    output reg [`AluSelBus] alusel,
    output reg [`AluOpBus] aluop,
    output reg [`RegBus] op1,
    output reg [`RegBus] op2,
    output reg write,
    output reg [`RegAddrBus] regw_addr
);

    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];
    wire [11:0] I_imm = inst[31:20];
    wire [19:0] U_imm = inst[31:12];
    wire [11:0] S_imm = {inst[31:25], inst[11:7]};

    wire [`RegAddrBus] rd = inst[11:7];
    wire [`RegAddrBus] rs = inst[19:15];
    wire [`RegAddrBus] rt = inst[24:20];

    reg [`RegBus] imm1, imm2;

    always @(*) begin
        if (reset) begin
            alusel <= 3'b000; aluop <= 0;
            read1 <= 0; reg1_addr <= 0; imm1 <= 0;
            read2 <= 0; reg2_addr <= 0; imm2 <= 0;
            write <= 0; regw_addr <= 0;
        end else begin
            case (opcode)
                7'b0000000: begin
                    alusel <= 3'b000; aluop <= 0;
                    read1 <= 0; reg1_addr <= 0; imm1 <= 0;
                    read2 <= 0; reg2_addr <= 0; imm2 <= 0;
                    write <= 0; regw_addr <= 0;
                end
                7'b0010011: begin
                    case (funct3)
                        3'b110: begin
                            alusel <= 3'b001; aluop <= 0;
                            read1 <= 1; reg1_addr <= rs; imm1 <= 0;
                            read2 <= 0; reg2_addr <= 0; imm2 <= {{20{I_imm[11]}}, I_imm};
                            write <= 1; regw_addr <= rd;
                        end
                    endcase
                end
            endcase
        end
    end

    always @(*) begin
        if (reset)
            op1 <= 0;
        else if (read1)
            op1 <= reg1_data;
        else
            op1 <= imm1;
    end

    always @(*) begin
        if (reset)
            op2 <= 0;
        else if (read2)
            op2 <= reg2_data;
        else
            op2 <= imm2;
    end

endmodule
