dune exec c4solver -- bench external-solver --step Bitboard --lang rust resources/Test_L3_R1 -- $PWD/target/release/c4solver --alpha-beta true --column-exploration-reorder true --position bitboard
dune exec c4solver -- bench external-solver --step Bitboard --weak --lang rust resources/Test_L3_R1 -- $PWD/target/release/c4solver --alpha-beta true --column-exploration-reorder true --position bitboard --weak
dune exec c4solver -- bench external-solver --step Bitboard --lang rust resources/Test_L2_R1 -- $PWD/target/release/c4solver --alpha-beta true --column-exploration-reorder true --position bitboard
dune exec c4solver -- bench external-solver --step Bitboard --weak --lang rust resources/Test_L2_R1 -- $PWD/target/release/c4solver --alpha-beta true --column-exploration-reorder true --position bitboard --weak
dune exec c4solver -- bench external-solver --step Bitboard --lang rust resources/Test_L2_R2 -- $PWD/target/release/c4solver --alpha-beta true --column-exploration-reorder true --position bitboard
dune exec c4solver -- bench external-solver --step Bitboard --weak --lang rust resources/Test_L2_R2 -- $PWD/target/release/c4solver --alpha-beta true --column-exploration-reorder true --position bitboard --weak
