set -e
rm -rf test
mkdir test
riscv32-unknown-elf-as -o sys/rom.o -march=rv32i sys/rom.s
cp testcase/$1.c test/test.c
riscv32-unknown-elf-gcc -o test/test.o -I sys -c test/test.c -O2 -march=rv32i -mabi=ilp32 -Wall
riscv32-unknown-elf-ld -T sys/memory.ld sys/rom.o test/test.o -L /opt/riscv/riscv32-unknown-elf/lib -L /opt/riscv/lib/gcc/riscv32-unknown-elf/8.3.0/ -lc -lgcc -lm -lnosys -o test/test.om
riscv32-unknown-elf-objcopy -O verilog test/test.om test/test.data
riscv32-unknown-elf-objcopy -O binary test/test.om test/test.bin
riscv32-unknown-elf-objdump -D test/test.om > test/test.dump
