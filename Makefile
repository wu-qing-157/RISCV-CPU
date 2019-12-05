out/sim: src/*.v
	iverilog -Isrc -Diverilog src/*.v -o out/testbench
