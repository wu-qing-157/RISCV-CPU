zsh sim_build.sh $1
if [ -f testcase/$1.in ]; then cp testcase/$1.in test/test.in; fi
if [ -f testcase/$1.ans ]; then cp testcase/$1.ans test/test.ans; fi
