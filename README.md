# RISCV-CPU

## Function Progress

+ 0 - Nothing
+ 1 - Partly
+ 2 - Finished
+ 3 - Tested

|Status|Function|
|----|----|
|3|Correct Output|
|0|FPGA Correct Output|
|0|5-Circle IF|
|0|Cache|
|0|Branch Prediction|

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
+ 2019.11.25 Single LOAD seems passed
+ 2019.11.26 Fix Data Forward with stall_mem
+ 2019.11.26 BRANCH with stall_id & stall_mem seems passed
+ 2019.11.26 Reconstruct ctrl_mem (untested)
+ 2019.11.26 Trivial Test pass
+ 2019.11.27 Pass many tests
+ 2019.11.28 Fix an issue in IF
