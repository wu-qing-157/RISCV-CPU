REMOTE?=1

out/test_bench: src/*.v
ifeq ($(REMOTE), 0)
	iverilog -Isrc -Diverilog src/test_bench.v -o out/test_bench
else
	scp -r src $$DOM:RISCV-CPU
	ssh $$DOM "cd RISCV-CPU ; iverilog -Isrc -Diverilog src/test_bench.v -o out/test_bench"
	scp $$DOM:RISCV-CPU/out/test_bench out
endif
