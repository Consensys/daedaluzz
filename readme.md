# Daedaluzz: A Benchmark Generator for Smart-Contract Fuzzers

Daedaluzz is a tool for automatically generating benchmarks for smart-contract fuzzers. The benchmark-generation approach takes inspiration from the [Fuzzle](https://softsec.kaist.ac.kr/~sangkilc/papers/lee-ase22.pdf) benchmark generator for C-based fuzzers.

A key goal is to make it possible to compare as many different fuzzers as possible. For this reason, the benchmarks intentionally use a limited subset of Solidity to avoid language features that some tools could handle differently (or not at all).

Each generated benchmark contract contains many assertions (some can fail, but others cannot due to infeasible path conditions). A fuzzer can create sequences of transactions that make those assertions fail. We can measure a fuzzer's performance by the number of distinct assertion violations that are found.

On a high level, each contract keeps track of the current position in a 2-dimensional maze of a fixed dimension (for instance, 7x7). Each transaction can move the current position to explore the maze. Some locations in the maze are unreachable (so-called "walls"), while others may contain a "bug" that can be found by the fuzzer when providing specific transaction inputs. Some of these bugs cannot be reached since the path conditions are infeasible.

We have used Daedaluzz to generate a set of 5 benchmark contracts (see `generated-mazes` folder). Yet, one can easily generate new ones by modifying the random seed and other hyperparameters (for instance, `numFuncParams`, `dimX`, and `maxDepth`).

One can also tweak the benchmark generator to emit custom benchmark variants for fuzzers that do not support the default benchmarks. For instance, we have used it to produce custom benchmark instances for the Foundry/Forge fuzzer (see files ending in `.foundry.sol` in the `generated-mazes` folder).

The repository also includes infrastructure (for instance, scripts and Dockerfiles) to run several popular fuzzers on the generated benchmarks:
- [Echidna](https://github.com/crytic/echidna)
- [Foundry/Forge](https://github.com/foundry-rs/foundry/tree/master/forge)
- [Harvey](https://mariachris.github.io/Pubs/FSE-2020-Harvey.pdf)
- [Hybrid-Echidna](https://github.com/crytic/optik)

