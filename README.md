# RISCV-CPU

A RISC-V CPU with standard 5-stage pipeline, implemented in Verilog HDL

## Feature, Performance

Please refer to the project report.

## Feature Progress

For feature details, please refer to project report.

Feature|Status
----|----
Simulation Correct Output|__Test OK__
FPGA Correct Output|__Test OK__
Data Forwarding|__Test OK__
IF Prefetch|__Test OK__
ICache (1-Cycle Hit)|__Test OK__
DCache (Write Back) (1-Cycle Hit)|__Test OK__
Write Buffer|__Test OK__
2-bit BTB|__Test OK__

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
+ 2020.01.02 Add BTB (pass some test)
+ 2020.01.02 Interrupt IF-read head when IO (cannot pass print_hello, gcd and hanoi)
+ 2020.01.03 Pass All Tests
+ 2020.01.03 Remove unused code
+ 2020.01.03 Add project report

## Test on FPGA

Test Name|Current
----|----
array_test1|0.000
array_test2|0.016
basicopt1|0.016
bulgarian|1.313 (extra sleep)
expr|0.031
gcd|0.016
hanoi|0.766
lvalue2|0.016
magic|0.031
manyarguments|0.000
multiarray|0.031
pi|0.469
qsort|3.500 (extra sleep)
queens|0.563
statement_test|0.016
superloop|0.016
tak|0.016
love|138.3
