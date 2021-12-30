In this test we monitor the accuracy of some algorithms when run on
the test data placed in the ./resources/ directory.

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step MinMax
  ┌────────┬────────────┬──────────┬────────────────┐
  │ solver │ test       │ accuracy │ mean nb of pos │
  ├────────┼────────────┼──────────┼────────────────┤
  │ MinMax │ Test_L3_R1 │  100.00% │         11_025 │
  └────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Alpha_beta
  ┌────────────┬────────────┬──────────┬────────────────┐
  │ solver     │ test       │ accuracy │ mean nb of pos │
  ├────────────┼────────────┼──────────┼────────────────┤
  │ Alpha-beta │ Test_L3_R1 │  100.00% │            284 │
  └────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Column_exploration_order
  ┌──────────────────────────┬────────────┬──────────┬────────────────┐
  │ solver                   │ test       │ accuracy │ mean nb of pos │
  ├──────────────────────────┼────────────┼──────────┼────────────────┤
  │ Column exploration order │ Test_L3_R1 │  100.00% │            140 │
  └──────────────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Column_exploration_order \
  > --weak
  ┌─────────────────────────────────┬────────────┬──────────┬────────────────┐
  │ solver                          │ test       │ accuracy │ mean nb of pos │
  ├─────────────────────────────────┼────────────┼──────────┼────────────────┤
  │ Column exploration order (weak) │ Test_L3_R1 │  100.00% │            107 │
  └─────────────────────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Bitboard
  ┌──────────┬────────────┬──────────┬────────────────┐
  │ solver   │ test       │ accuracy │ mean nb of pos │
  ├──────────┼────────────┼──────────┼────────────────┤
  │ Bitboard │ Test_L3_R1 │  100.00% │            140 │
  └──────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Bitboard --weak
  ┌─────────────────┬────────────┬──────────┬────────────────┐
  │ solver          │ test       │ accuracy │ mean nb of pos │
  ├─────────────────┼────────────┼──────────┼────────────────┤
  │ Bitboard (weak) │ Test_L3_R1 │  100.00% │            107 │
  └─────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Transposition_table
  ┌─────────────────────┬────────────┬──────────┬────────────────┐
  │ solver              │ test       │ accuracy │ mean nb of pos │
  ├─────────────────────┼────────────┼──────────┼────────────────┤
  │ Transposition table │ Test_L3_R1 │  100.00% │             93 │
  └─────────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Transposition_table \
  > --weak
  ┌────────────────────────────┬────────────┬──────────┬────────────────┐
  │ solver                     │ test       │ accuracy │ mean nb of pos │
  ├────────────────────────────┼────────────┼──────────┼────────────────┤
  │ Transposition table (weak) │ Test_L3_R1 │  100.00% │             69 │
  └────────────────────────────┴────────────┴──────────┴────────────────┘
  
  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Iterative_deepening
  ┌─────────────────────┬────────────┬──────────┬────────────────┐
  │ solver              │ test       │ accuracy │ mean nb of pos │
  ├─────────────────────┼────────────┼──────────┼────────────────┤
  │ Iterative deepening │ Test_L3_R1 │  100.00% │            132 │
  └─────────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --step Iterative_deepening \
  > --weak
  ┌────────────────────────────┬────────────┬──────────┬────────────────┐
  │ solver                     │ test       │ accuracy │ mean nb of pos │
  ├────────────────────────────┼────────────┼──────────┼────────────────┤
  │ Iterative deepening (weak) │ Test_L3_R1 │  100.00% │             74 │
  └────────────────────────────┴────────────┴──────────┴────────────────┘
  
