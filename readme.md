# Daedaluzz: A Benchmark Generator for Smart-Contract Fuzzers

*Daedaluzz is a tool for automatically generating benchmarks for smart-contract fuzzers. The benchmark-generation approach takes inspiration from the [Fuzzle](https://softsec.kaist.ac.kr/~sangkilc/papers/lee-ase22.pdf) benchmark generator for C-based fuzzers.*

*A key goal is to make it possible to compare as many different fuzzers as possible. For this reason, the benchmarks intentionally use a limited subset of Solidity to avoid language features that some tools could handle differently (or not at all).*

## Benchmark-Generation Approach

Each generated benchmark contract contains many assertions (some can fail, but others cannot due to infeasible path conditions). A fuzzer can create sequences of transactions that make those assertions fail. We can measure a fuzzer's performance by the number of distinct assertion violations that are found.

On a high level, each contract keeps track of the current position in a 2-dimensional maze of a fixed dimension (for instance, 7x7). Each transaction can move the current position to explore the maze. Some locations in the maze are unreachable (so-called "walls"), while others may contain a "bug" that can be found by the fuzzer when providing specific transaction inputs. Some of these bugs cannot be reached since the path conditions are infeasible.

The generated benchmarks try to capture two key challenges when fuzzing smart contracts:
1. code that can only be reached by satisfying complex transaction-input constraints
2. code that can only be reached by first reaching a specific state of the contract through multiple prior transactions

In the future, we may extend the benchmark generator to incorporate other challenges we often encounter when fuzzing real-world contracts. We are more than happy to discuss ideas for such extensions!

## Benchmark Examples

We have used Daedaluzz to generate a set of 5 benchmark contracts (see `generated-mazes` folder). Yet, one can easily generate new ones by modifying the [random seed](https://github.com/ConsenSys/daedaluzz/blob/2c163f4ed12484203345e1df2c619ba53739885d/main.go#L158) and other hyperparameters (for instance, [`numFuncParams`](https://github.com/ConsenSys/daedaluzz/blob/2c163f4ed12484203345e1df2c619ba53739885d/main.go#L159), [`dimX`](https://github.com/ConsenSys/daedaluzz/blob/2c163f4ed12484203345e1df2c619ba53739885d/main.go#L161), and [`maxDepth`](https://github.com/ConsenSys/daedaluzz/blob/2c163f4ed12484203345e1df2c619ba53739885d/main.go#L164)).

One can also tweak the benchmark generator to emit custom benchmark variants for fuzzers that do not support the default benchmarks. For instance, we have used it to produce custom benchmark instances for the Foundry/Forge fuzzer; see the [`foundry-code-generation`](https://github.com/ConsenSys/daedaluzz/tree/foundry-code-generation) branch and the files ending in `.foundry.sol` in the `generated-mazes` folder.

## Benchmarking Infrastructure

The repository also includes infrastructure (for instance, scripts and Dockerfiles) to run several popular fuzzers on the generated benchmarks:
- [Echidna](https://github.com/crytic/echidna)
- [Foundry/Forge](https://github.com/foundry-rs/foundry/tree/master/forge)
- [Harvey](https://mariachris.github.io/Pubs/FSE-2020-Harvey.pdf)
- [Hybrid-Echidna](https://github.com/crytic/optik)

The `run-all-fuzzers.sh` script can be used to benchmark the above fuzzers, and the `show-stats.py` script can be used to aggregate and visualize the results.
