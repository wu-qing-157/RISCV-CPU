REMOTE?=1

out/test1: src/*.v
ifeq ($(REMOTE), 0)
	iverilog -Isrc -Diverilog src/test1.v -o out/test1
else
	scp -r src $$DOM:RISCV-CPU
	ssh $$DOM "cd RISCV-CPU ; iverilog -Isrc -Diverilog src/test1.v -o out/test1"
	scp $$DOM:RISCV-CPU/out/test1 out
endif
