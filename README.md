# RISCV-CPU

## Function Progress

+ 0 - Nothing
+ 1 - Partly
+ 2 - Finished
+ 3 - Tested

|Status|Function|
|----|----|
|1|Basic Flow|
|0|Stall Control|
|0|Memory Control|
|1|Data Forward|
|0|Cache|

## Instruction Progress

+ 0 - Nothing
+ 1 - Finished
+ 2 - Tested

|Status|Instruction|
|----|----|
|0|LUI|
|0|AUIPC|
|0|JAL|
|0|JALR|
|0|BEQ|
|0|BNE|
|0|BLT|
|0|BGE|
|0|BLTU|
|0|BGEU|
|0|LB|
|0|LH|
|0|LW|
|0|LBU|
|0|LHU|
|0|SB|
|0|SH|
|0|SW|
|2|ADDI|
|2|SLTI|
|2|SLTIU|
|2|XORI|
|2|ORI|
|2|ANDI|
|2|SLLI|
|2|SRLI|
|2|SRAI|
|2|ADD|
|2|SUB|
|2|SLL|
|2|SLT|
|2|SLTU|
|2|XOR|
|2|SRL|
|2|SRA|
|2|OR|
|2|AND|
|0|FENCE|
|0|FENCE.I|

## Timeline

+ 2019.11.12 Finish ori (as MIPS) (pass compilation)
+ 2019.11.20 ori (pass result check)
+ 2019.11.20 Change into RV32I (untested)
+ 2019.11.22 Reconstruct lots of code (untested)
+ 2019.11.22 ori (pass test)
+ 2019.11.22 Add OP_OP and OP_IMM (untested)
+ 2019.11.22 Add Data Forward (naive) (untested)
+ 2019.11.23 Data Forward (naive) (pass test)
+ 2019.11.23 OP_OP and OP_IMM (pass test)
