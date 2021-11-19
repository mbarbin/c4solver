In this test we monitor the accuracy of some algorithms when run on
the test data placed in the ./resources/ directory.

  $ c4solver bench ./Test_L3_R1 --accuracy-only --alpha-beta false \
  > --column-exploration-reorder false --position basic
  ┌────────────┬──────────┐
  │       test │ accuracy │
  ├────────────┼──────────┤
  │ Test_L3_R1 │  100.00% │
  └────────────┴──────────┘
  

  $ c4solver bench ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position basic
  ┌────────────┬──────────┐
  │       test │ accuracy │
  ├────────────┼──────────┤
  │ Test_L3_R1 │  100.00% │
  └────────────┴──────────┘
  

  $ c4solver bench ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position basic --weak
  ┌────────────┬──────────┐
  │       test │ accuracy │
  ├────────────┼──────────┤
  │ Test_L3_R1 │  100.00% │
  └────────────┴──────────┘
  

  $ c4solver bench ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position bitboard
  ┌────────────┬──────────┐
  │       test │ accuracy │
  ├────────────┼──────────┤
  │ Test_L3_R1 │  100.00% │
  └────────────┴──────────┘
  
  $ c4solver bench ./Test_L3_R1 --accuracy-only --alpha-beta true \
  > --column-exploration-reorder true --position bitboard --weak
  ┌────────────┬──────────┐
  │       test │ accuracy │
  ├────────────┼──────────┤
  │ Test_L3_R1 │  100.00% │
  └────────────┴──────────┘
  
