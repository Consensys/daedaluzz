#!/bin/bash
cd /daedaluzz
solc-select install 0.8.19
solc-select use 0.8.19
rm -rf hybrid-echidna-tmp/task-$1
mkdir hybrid-echidna-tmp/task-$1
cd hybrid-echidna-tmp/task-$1
rm -rf hybrid-echidna-corpus
mkdir hybrid-echidna-corpus

# Default settings:
# - seq-len: 10
# - test-limit: 50000
# - max-iters: unspecified
# - solver-timeout: unspecified
# - no-incremental: false
SEQ_LEN=100  # We also tried 30, but did not observe a significant change in performance. We use the default value for Echidna.
TEST_LIMIT='--test-limit 50000'
MAX_ITERS='--max-iters 3'
SOLVER_TIMEOUT=''
NO_INCREMENTAL=''
BRANCH_RECORD_PROB=''
SHRINK_LIMIT=5000  # We use the default value for Echidna.
CODE_SIZE='0xc00000'
printf 'shrinkLimit: %s\ncodeSize: %s\n' $SHRINK_LIMIT $CODE_SIZE > echidna-config.yaml
INIT_SEED=$4
RANDOM=$INIT_SEED
START_TIME=$(date +%s)
TIME_LIMIT=$2
END_TIME=$((START_TIME + TIME_LIMIT))
while true; do
    NOW_TIME=$(date +%s)
    echo "{\"timestamp\": $NOW_TIME}"
    if [ $END_TIME -le $NOW_TIME ]; then
        break
    fi
    SEED=$RANDOM
    echo "{\"random-seed\": $SEED}"
    REM_TIME=$((END_TIME - NOW_TIME))
    # TERM='xterm-256color' timeout --foreground --preserve-status --kill-after 120 --signal SIGINT $REM_TIME hybrid-echidna /daedaluzz/generated-mazes/maze-$3.sol --config echidna-config.yaml --test-mode exploration --corpus-dir hybrid-echidna-corpus --contract Maze --seq-len $SEQ_LEN $TEST_LIMIT $MAX_ITERS $SOLVER_TIMEOUT $NO_INCREMENTAL $BRANCH_RECORD_PROB --seed $SEED > /dev/null 2>&1
    TERM='xterm-256color' timeout --foreground --preserve-status --kill-after 120 --signal SIGINT $REM_TIME hybrid-echidna /daedaluzz/generated-mazes/maze-$3.sol --config echidna-config.yaml --test-mode exploration --corpus-dir hybrid-echidna-corpus --contract Maze --seq-len $SEQ_LEN $TEST_LIMIT $MAX_ITERS $SOLVER_TIMEOUT $NO_INCREMENTAL $BRANCH_RECORD_PROB --seed $SEED --no-display
    grep "[*roe]\s*|\s*emit AssertionFailed" hybrid-echidna-corpus/covered.*.txt
    TEST_LIMIT='--test-limit 500'
    MAX_ITERS='--max-iters 1'
    # SOLVER_TIMEOUT='--solver-timeout 5000'
    NO_INCREMENTAL='--no-incremental'
    # BRANCH_RECORD_PROB='--branch-record-prob "0.1"'
done
