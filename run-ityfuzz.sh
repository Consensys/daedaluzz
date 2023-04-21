cd /daedaluzz
solc-select install 0.8.19
solc-select use 0.8.19
rm -rf ityfuzz-tmp/task-$1
mkdir -p ityfuzz-tmp/task-$1
cd ityfuzz-tmp/task-$1
rm -rf corpus
mkdir corpus

solc /daedaluzz/generated-mazes/maze-$3.sol --abi --bin --overwrite -o build/ --optimize --optimize-runs 99999

TIME_LIMIT=$2
timeout $TIME_LIMIT /bins/cli_print_logs -t "build/*" | grep log

