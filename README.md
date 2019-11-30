# RISCV-CPU

## Feature Progress

|Feature|Status|
|----|----|
|Correct Output|Maybe Incorrect (Working with Cache)|
|FPGA Correct Output|Not started|
|4-Circle IF|No major work|
|ICache|Pass some tests, WA with "queens"|
|DCache|Not started|
|Branch Prediction|Not started|

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
+ 2019.11.28 Fix an issue in ctrl_stall
+ 2019.11.28 Add ICache (pass some tests, cannot pass some tests)
+ 2019.11.28 Fix several issues about data hazard
+ 2019.11.29 Fix an issue about data hazard (branch after load)

## Test Cases

|Test Name|aedf0cf|Current|
|----|----|----|
|basicopt1|6432481|3921803|
|bulgarian|9073277|5531041|
|expr|91087|25869|
|gcd|13129|7123|
|lvalue2|219|219|
|magic|7091975|5634177|
|manyarguments|353|353|
|multiarray|81339|55637|
|pi (1000)|10134767|3296955|
|qsort (1000)|4787333|2041527|
|queens|5773345|__WA__|
