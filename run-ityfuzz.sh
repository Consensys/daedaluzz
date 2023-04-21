cd /daedaluzz
solc-select install 0.8.19
solc-select use 0.8.19
rm -rf ityfuzz-tmp/task-$1
mkdir ityfuzz-tmp/task-$1
cd ityfuzz-tmp/task-$1
rm -rf corpus
mkdir corpus

solc /daedaluzz/generated-mazes/maze-$3.sol --abi --bin --overwrite -o ityfuzz-tmp/ --optimize --optimize-runs 99999

TIME_LIMIT=$2
timeout -n $TIME_LIMIT /bins/ityfuzz-offchain -t "ityfuzz-tmp/*" | grep log
