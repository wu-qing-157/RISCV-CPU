# RISCV-CPU

## Cycle Details

Description|Cycles
----|----
IF (Cache Miss)|7
IF (Contiguous Cache Miss without Branch)|4
IF (Cache Hit)|1
IF (Branch Prediction Error with Cache Miss)|9
IF (Branch Prediction Error with Cache Hit)|3
ID|1
EX|1
MEM (Read Cache Miss)|length + 3 + Additional if Write Buffer Busy
MEM (Read Cache Hit)|1
MEM (Write)|1 + Additional if Flush Needed and Write Buffer Busy
WB|1

## Feature Progress

Feature|Status
----|----
Simulation Correct Output|__Test OK__
FPGA Correct Output|__Test OK__
Optimize IF Cycles|__Test OK__, Pending Interruptable by MEM
1-Cycle Cache-Hit IF|__Test OK__
DCache|__Test OK__
Write Buffer|__Test OK__, Pending Reduce Priority
Branch Prediction|__Test OK__, Current: Always Predict no Branch

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
+ 2019.12.27 Optimize some codes
+ 2019.12.28 Add an extra cycle to cache miss to reduce cycle time
+ 2019.12.28 Add IF-read ahead to mem_ctrl
+ 2019.12.28 Fix cache offset
+ 2019.12.29 Add DCache (pass some tests)
+ 2019.12.29 Reduce Time Slack & Pass tests on FPGA without input
+ 2019.12.29 DCache pass all tests on FPGA
+ 2019.12.29 Change mem_ctrl priority
+ 2019.12.30 Add Write Buffer (pass all tests on FPGA)
+ 2020.01.01 IF Read Ahead Interruptable

## Simulation Test Cases

Test Name|aedf0cf|1f7a93d|e9bd94e|8a0e2ef|358a5cf|b833ffa|5e1048a|2fbd2e2
----|----|----|----|----|----|----|----|----
basicopt1|6432481|3921803|4303755|4319783|3586405|2124699|2390181|2111249
bulgarian|9073277|5531041|6041243|6129043|5436831|3195399|2762323|2482579
expr|91087|25869|32151|33241|30895|24479|24535|23677
gcd|13129|7123|7941|8003|7171|4667|4675|4087
lvalue2|219|219|223|227|199|199|243|197
magic|7091975|5631839|5796301|5826219|5400941|3123099|2376481|1939991
manyarguments|353|353|357|361|327|327|385|313
multiarray|81339|55637|60289|60573|51309|37267|42659|33575
pi (1000)|10134767|3296955|3995597|4117307|3775945|2565651|2554391|2530517
qsort (1000)|4787333|2041527|2327071|2363023|2165759|1271419|1212889|1157307
queens|5773345|3268907|3408607|3459811|3298751|2106301|1384893|1243179

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
