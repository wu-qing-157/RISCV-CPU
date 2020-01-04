zsh fpga_build.sh $1
if [ -f ./testcase/$1.in ]; then cp ./testcase/$1.in ./test/test.in; fi
if [ -f ./testcase/$1.ans ]; then cp ./testcase/$1.ans ./test/test.ans; fi
zsh ctrl/build.sh
echo Answer:
cat test/test.ans
echo
zsh ctrl/run.sh test/test.bin test/test.in /dev/$fpga_port -I
#./ctrl/run.sh ./test/test.bin ./test/test.in /dev/tty$$port -T > ./test/test.out
#if [ -f ./test/test.ans ]; then diff ./test/test.ans ./test/test.out; fi
