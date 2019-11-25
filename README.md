# RISCV-CPU

## Function Progress

+ 0 - Nothing
+ 1 - Partly
+ 2 - Finished
+ 3 - Tested

|Status|Function|
|----|----|
|2|Basic Flow|
|2|Stall Control|
|2|Memory Control|
|3|Data Forward|
|0|Cache|

## Instruction Progress

+ 0 - Nothing
+ 1 - Finished
+ 2 - Tested

|Status|Instruction|
|----|----|
|2|LUI|
|1|AUIPC|
|1|JAL|
|1|JALR|
|1|BEQ|
|1|BNE|
|1|BLT|
|1|BGE|
|1|BLTU|
|1|BGEU|
|1|LB|
|1|LH|
|1|LW|
|1|LBU|
|1|LHU|
|1|SB|
|1|SH|
|1|SW|
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
+ 2019.11.23 Add JUMP and BRANCH (not pass compilation)
+ 2019.11.23 Add ctrl_stall (not pass compilation)
+ 2019.11.25 Add MEM (not pass compilation)
+ 2019.11.25 IF pass simple test
+ 2019.11.25 JAL seems passed
