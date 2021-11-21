# c4solver

![main workflow](https://github.com/mbarbin/c4solver/actions/workflows/main.yml/badge.svg)

This is a toy project implementing a solver for the connect4 game,
written in OCaml.

## Acknowledgements and License

The work in this repository was heavily inspired by Pascal Pons'
tutorial, which is published online there:

- http://blog.gamesolver.org/solving-connect-four/01-introduction/

The source code behind the tutorial is available here:

- https://github.com/PascalPons/connect4

This is a cpp implementation published under AGPL v3 license.

In this repo, we do not use nor depend on the original tutorial source
code (this solver is implemented in OCaml rather than cpp).

However, some parts of the code are heavily inspired by the original
cpp code, either by direct code translation, and/or further modified.

Moreover, we do import some of the testing resources used in the
original repository, verbatim. See `resources/`.

Note also, some documentation comments were kept from the original.

Due to these considerations, we have kept the original AGPL v3 License
for this repo as well.

## Motivations

- Pedagogic: Learn about the concepts involved - minimax, alpha-beta
  pruning, transposition tables, iterative deepening, etc.
- Benchmark: Reproduce and compare performance results. Experiment
  with various code changes and witness their impact on performances.
