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
|0|Data Forward (EX)|
|0|Data Forward (MEM)|
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
|0|ADDI|
|0|SLTI|
|0|SLTIU|
|0|XORI|
|2|ORI|
|0|ANDI|
|0|SLLI|
|0|SRLI|
|0|SRAI|
|0|ADD|
|0|SUB|
|0|SLL|
|0|SLT|
|0|SLTU|
|0|XOR|
|0|SRL|
|0|SRA|
|0|OR|
|0|AND|
|0|FENCE|
|0|FENCE.I|

## Timeline

+ 2019.11.12 Finish ori (as MIPS) (pass compilation)
+ 2019.11.20 ori (pass result check)
+ 2019.11.20 Change into RV32I (untested)
+ 2019.11.22 Reconstruct lots of code (untested)
+ 2019.11.22 ori (pass test)
