# c4solver

[![Actions Status](https://github.com/mbarbin/c4solver/workflows/CI/badge.svg)](https://github.com/mbarbin/c4solver/actions)

This is a toy project implementing a solver for the connect4 game,
written in OCaml and Rust, based on Pascal Pons' original work.

## Acknowledgements and License

The work in this repository is a replication of (the excellent) Pascal
Pons' tutorial, which is published online there:

- http://blog.gamesolver.org/solving-connect-four/01-introduction/

The original cpp source code behind the tutorial is published under
AGPL v3 Licence and is available here:

- https://github.com/PascalPons/connect4

The code in this repository is based on the original cpp code, by
direct code translation, and/or further modified. Some documentation
comments were kept as-is from the original, some new comments were
added.

Moreover, we do import some of the testing resources used in the
original repository, verbatim. See `resources/`.

We have kept the original AGPL v3 License for this repo as well.

## Motivations

- Pedagogic: Learn about the concepts involved - minimax, alpha-beta
  pruning, transposition tables, iterative deepening, etc.
- Benchmark: Reproduce and compare performance results. Experiment
  with various code changes and witness their impact on performances,
  compare OCaml with Rust, etc.
