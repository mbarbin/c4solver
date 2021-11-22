In this test we monitor the accuracy of some algorithms when run on
the test data placed in the ./resources/ directory.

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --alpha-beta false \
  > --column-exploration-reorder false --position basic
  ┌────────┬────────────┬──────────┬────────────────┐
  │ solver │ test       │ accuracy │ mean nb of pos │
  ├────────┼────────────┼──────────┼────────────────┤
  │ MinMax │ Test_L3_R1 │  100.00% │         11_025 │
  └────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder false --position basic
  ┌────────────┬────────────┬──────────┬────────────────┐
  │ solver     │ test       │ accuracy │ mean nb of pos │
  ├────────────┼────────────┼──────────┼────────────────┤
  │ Alpha-beta │ Test_L3_R1 │  100.00% │            284 │
  └────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position basic
  ┌──────────────────────────┬────────────┬──────────┬────────────────┐
  │ solver                   │ test       │ accuracy │ mean nb of pos │
  ├──────────────────────────┼────────────┼──────────┼────────────────┤
  │ Column exploration order │ Test_L3_R1 │  100.00% │            140 │
  └──────────────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position basic --weak
  ┌─────────────────────────────────┬────────────┬──────────┬────────────────┐
  │ solver                          │ test       │ accuracy │ mean nb of pos │
  ├─────────────────────────────────┼────────────┼──────────┼────────────────┤
  │ Column exploration order (weak) │ Test_L3_R1 │  100.00% │            107 │
  └─────────────────────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position bitboard
  ┌──────────┬────────────┬──────────┬────────────────┐
  │ solver   │ test       │ accuracy │ mean nb of pos │
  ├──────────┼────────────┼──────────┼────────────────┤
  │ Bitboard │ Test_L3_R1 │  100.00% │            140 │
  └──────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position bitboard --weak
  ┌─────────────────┬────────────┬──────────┬────────────────┐
  │ solver          │ test       │ accuracy │ mean nb of pos │
  ├─────────────────┼────────────┼──────────┼────────────────┤
  │ Bitboard (weak) │ Test_L3_R1 │  100.00% │            107 │
  └─────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position bitboard \
  > --with-transposition-table true
  ┌─────────────────────┬────────────┬──────────┬────────────────┐
  │ solver              │ test       │ accuracy │ mean nb of pos │
  ├─────────────────────┼────────────┼──────────┼────────────────┤
  │ Transposition table │ Test_L3_R1 │  100.00% │             93 │
  └─────────────────────┴────────────┴──────────┴────────────────┘
  

  $ c4solver bench run ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position bitboard --weak \
  > --with-transposition-table true
  ┌────────────────────────────┬────────────┬──────────┬────────────────┐
  │ solver                     │ test       │ accuracy │ mean nb of pos │
  ├────────────────────────────┼────────────┼──────────┼────────────────┤
  │ Transposition table (weak) │ Test_L3_R1 │  100.00% │             69 │
  └────────────────────────────┴────────────┴──────────┴────────────────┘
  
