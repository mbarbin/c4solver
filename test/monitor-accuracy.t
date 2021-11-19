In this test we monitor the accuracy of some algorithms when run on
the test data placed in the ./resources/ directory.

  $ c4solver bench ./Test_L3_R1 --accuracy-only --alpha-beta false \
  > --column-exploration-reorder false --position basic
  ┌────────────┬──────────┬────────────────┐
  │       test │ accuracy │ mean nb of pos │
  ├────────────┼──────────┼────────────────┤
  │ Test_L3_R1 │  100.00% │         11_024 │
  └────────────┴──────────┴────────────────┘
  

  $ c4solver bench ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder false --position basic
  ┌────────────┬──────────┬────────────────┐
  │       test │ accuracy │ mean nb of pos │
  ├────────────┼──────────┼────────────────┤
  │ Test_L3_R1 │  100.00% │            283 │
  └────────────┴──────────┴────────────────┘
  

  $ c4solver bench ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position basic
  ┌────────────┬──────────┬────────────────┐
  │       test │ accuracy │ mean nb of pos │
  ├────────────┼──────────┼────────────────┤
  │ Test_L3_R1 │  100.00% │            139 │
  └────────────┴──────────┴────────────────┘
  

  $ c4solver bench ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position basic --weak
  ┌────────────┬──────────┬────────────────┐
  │       test │ accuracy │ mean nb of pos │
  ├────────────┼──────────┼────────────────┤
  │ Test_L3_R1 │  100.00% │            107 │
  └────────────┴──────────┴────────────────┘
  

  $ c4solver bench ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position bitboard
  ┌────────────┬──────────┬────────────────┐
  │       test │ accuracy │ mean nb of pos │
  ├────────────┼──────────┼────────────────┤
  │ Test_L3_R1 │  100.00% │            139 │
  └────────────┴──────────┴────────────────┘
  

  $ c4solver bench ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position bitboard --weak
  ┌────────────┬──────────┬────────────────┐
  │       test │ accuracy │ mean nb of pos │
  ├────────────┼──────────┼────────────────┤
  │ Test_L3_R1 │  100.00% │            107 │
  └────────────┴──────────┴────────────────┘
  

  $ c4solver bench ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position bitboard \
  > --with-transposition-table true
  ┌────────────┬──────────┬────────────────┐
  │       test │ accuracy │ mean nb of pos │
  ├────────────┼──────────┼────────────────┤
  │ Test_L3_R1 │  100.00% │             92 │
  └────────────┴──────────┴────────────────┘
  

  $ c4solver bench ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position bitboard --weak \
  > --with-transposition-table true
  ┌────────────┬──────────┬────────────────┐
  │       test │ accuracy │ mean nb of pos │
  ├────────────┼──────────┼────────────────┤
  │ Test_L3_R1 │  100.00% │             68 │
  └────────────┴──────────┴────────────────┘
  
