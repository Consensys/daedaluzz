#!/bin/bash
cd /daedaluzz
solc-select install 0.8.19
solc-select use 0.8.19
rm -rf echidna-tmp/task-$1
mkdir echidna-tmp/task-$1
cd echidna-tmp/task-$1
rm -rf echidna-corpus
mkdir echidna-corpus

# Default settings:
# - testLimit: 50000
# - shrinkLimit: 5000
# - codeSize: 0x6000
TEST_LIMIT=1073741823
SHRINK_LIMIT=5000  # We also tried 0, but did not observe a noticeable change in performance.
CODE_SIZE='0xc00000'
TIME_LIMIT=$2
SEED=$4
printf 'testMode: "exploration"\ntestLimit: %s\nstopOnFail: false\ntimeout: %s\nseqLen: 100\nshrinkLimit: %s\ncoverage: true\nformat: text\ncodeSize: %s\nseed: %d\ncorpusDir: echidna-corpus\n' $TEST_LIMIT $TIME_LIMIT $SHRINK_LIMIT $CODE_SIZE $SEED > echidna-config.yaml
echidna-test --config echidna-config.yaml --contract Maze /daedaluzz/generated-mazes/maze-$3.sol
grep "[*roe]\s*|\s*emit AssertionFailed" echidna-corpus/covered.*.txt
