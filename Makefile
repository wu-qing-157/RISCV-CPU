out/test1: src/*.v
	iverilog -Isrc -Diverilog src/test1.v -o out/test1

out/test2: src/*.v
	iverilog -Isrc -Diverilog src/test2.v -o out/test2

out/testbench: src/*.v
	iverilog -Isrc -Diverilog src/testbench.v -o out/testbench

data/test1.data: test_gen/Test1GenKt.class
	cd test_gen; kotlin Test1GenKt > ../data/test1.data

test_gen/Test1GenKt.class: test_gen/Test1Gen.kt
	cd test_gen; kotlinc Test1Gen.kt

