In this test we monitor the accuracy of some algorithms when run on
the test data placed in the ./resources/ directory.

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step MinMax
  ┌──────────────┬────────────┬──────────┬────────────────┐
  │ solver       │ test       │ accuracy │ mean nb of pos │
  ├──────────────┼────────────┼──────────┼────────────────┤
  │ MinMax ocaml │ Test_L3_R1 │  100.00% │         11_025 │
  └──────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Alpha_beta
  ┌──────────────────┬────────────┬──────────┬────────────────┐
  │ solver           │ test       │ accuracy │ mean nb of pos │
  ├──────────────────┼────────────┼──────────┼────────────────┤
  │ Alpha-beta ocaml │ Test_L3_R1 │  100.00% │            284 │
  └──────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Column_exploration_order
  ┌────────────────────────────────┬────────────┬──────────┬────────────────┐
  │ solver                         │ test       │ accuracy │ mean nb of pos │
  ├────────────────────────────────┼────────────┼──────────┼────────────────┤
  │ Column exploration order ocaml │ Test_L3_R1 │  100.00% │            140 │
  └────────────────────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Column_exploration_order \
  > --weak
  ┌───────────────────────────────────────┬────────────┬──────────┬────────────────┐
  │ solver                                │ test       │ accuracy │ mean nb of pos │
  ├───────────────────────────────────────┼────────────┼──────────┼────────────────┤
  │ Column exploration order (weak) ocaml │ Test_L3_R1 │  100.00% │            107 │
  └───────────────────────────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Bitboard
  ┌────────────────┬────────────┬──────────┬────────────────┐
  │ solver         │ test       │ accuracy │ mean nb of pos │
  ├────────────────┼────────────┼──────────┼────────────────┤
  │ Bitboard ocaml │ Test_L3_R1 │  100.00% │            140 │
  └────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Bitboard --weak
  ┌───────────────────────┬────────────┬──────────┬────────────────┐
  │ solver                │ test       │ accuracy │ mean nb of pos │
  ├───────────────────────┼────────────┼──────────┼────────────────┤
  │ Bitboard (weak) ocaml │ Test_L3_R1 │  100.00% │            107 │
  └───────────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Transposition_table
  ┌───────────────────────────┬────────────┬──────────┬────────────────┐
  │ solver                    │ test       │ accuracy │ mean nb of pos │
  ├───────────────────────────┼────────────┼──────────┼────────────────┤
  │ Transposition table ocaml │ Test_L3_R1 │  100.00% │             93 │
  └───────────────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Transposition_table \
  > --weak
  ┌──────────────────────────────────┬────────────┬──────────┬────────────────┐
  │ solver                           │ test       │ accuracy │ mean nb of pos │
  ├──────────────────────────────────┼────────────┼──────────┼────────────────┤
  │ Transposition table (weak) ocaml │ Test_L3_R1 │  100.00% │             69 │
  └──────────────────────────────────┴────────────┴──────────┴────────────────┘
  
  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Iterative_deepening
  ┌───────────────────────────┬────────────┬──────────┬────────────────┐
  │ solver                    │ test       │ accuracy │ mean nb of pos │
  ├───────────────────────────┼────────────┼──────────┼────────────────┤
  │ Iterative deepening ocaml │ Test_L3_R1 │  100.00% │            132 │
  └───────────────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Iterative_deepening \
  > --weak
  ┌──────────────────────────────────┬────────────┬──────────┬────────────────┐
  │ solver                           │ test       │ accuracy │ mean nb of pos │
  ├──────────────────────────────────┼────────────┼──────────┼────────────────┤
  │ Iterative deepening (weak) ocaml │ Test_L3_R1 │  100.00% │             74 │
  └──────────────────────────────────┴────────────┴──────────┴────────────────┘
  
