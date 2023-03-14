#!/bin/ash
cd /daedaluzz
rm -rf foundry-tmp/task-$1
mkdir foundry-tmp/task-$1
cd foundry-tmp/task-$1
forge init --no-git foundry-project
cd foundry-project
cp /daedaluzz/generated-mazes/maze-$3.foundry.sol test/maze-$3.t.sol
cp foundry.toml foundry.original.toml
forge build

# Default settings:
# - fuzz.runs: 256
# - fuzz.max_test_rejects: 65536
# - invariant.runs: 256
# - invariant.depth: 15
RUNS=500  # We also tried several other values, but did not observe a significant change in performance
MAX_TEST_REJECTS=1073741823
DEPTH=100  # We also tried 15 and 30, but observed lower performance.
INIT_SEED=$4
RANDOM=$INIT_SEED
START_TIME=$(date +%s)
TIME_LIMIT=$2
END_TIME=$((START_TIME + TIME_LIMIT))
while true; do
    NOW_TIME=$(date +%s)
    echo "{\"timestamp\": $NOW_TIME}"
    if [ $END_TIME -lt $NOW_TIME ]; then
        break
    fi
    SEED=$RANDOM
    echo "{\"random-seed\": $SEED}"
    HEX_SEED=$(printf "0x%x" $SEED)
    cp foundry.original.toml foundry.toml
    printf "\n[fuzz]\nruns = %s\nmax_test_rejects = %s\nseed = '%s'\ndictionary_weight = 40\ninclude_storage = true\ninclude_push_bytes = true\n\n[invariant]\nruns = %s\ndepth = %s\nfail_on_revert = false\ncall_override = false\ndictionary_weight = 80\ninclude_storage = true\ninclude_push_bytes = true\n" $RUNS $MAX_TEST_REJECTS $HEX_SEED $RUNS $DEPTH  >> foundry.toml
    forge test --match-path test/maze-$3.t.sol --fuzz-seed $HEX_SEED
done
