# RISCV-CPU

## Feature Progress

|Feature|Status|
|----|----|
|Simulation Correct Output|__Test OK__|
|FPGA Correct Output|__Test OK__|
|5-Cycle Cache-Miss IF|No major work|
|1-Cycle Cache-Hit IF|__Test OK__|
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
+ 2019.11.30 Fix an issue in stage_ex (store after load)
+ 2019.12.09 Fix some (maybe meaningless) bugs
+ 2019.12.11 Decrease time slack to 4.865ns (reconstruct branch)
+ 2019.12.12 Delay br one more cycle (not very useful)
+ 2019.12.25 Reconstruct cache and fix all inferring latch
+ 2019.12.26 Pass several tests on FPGA
+ 2019.12.27 Invalidate cache_i when resetting
+ 2019.12.27 Pass all tests on FPGA

## Simulation Test Cases

Test Name|aedf0cf|1f7a93d|e9bd94e3|Current
----|----|----|----|----
basicopt1|6432481|3921803|4303755|4319783
bulgarian|9073277|5531041|6041243|6129043
expr|91087|25869|32151|33241
gcd|13129|7123|7941|8003
lvalue2|219|219|223|227
magic|7091975|5631839|5796301|5826219
manyarguments|353|353|357|361
multiarray|81339|55637|60289|60573
pi (1000)|10134767|3296955|3995597|4117307
qsort (1000)|4787333|2041527|2327071|2363023
queens|5773345|3268907|3408607|3459811

## FPGA Test Cases

Test Name|Current
----|----
array_test1|__Pass__
array_test2|__Pass__
basicopt1|__Pass__
bulgarian|__Pass__
expr|__Pass__
gcd|__Pass__
hanoi|__Pass__
lvalue2|__Pass__
magic|__Pass__
manyarguments|__Pass__
multiarray|__Pass__
pi|__Pass__
qsort|__Pass__
queens|__Pass__
statement_test|__Pass__
superloop|__Pass__
tak|__Pass__
