dune exec c4solver -- bench external-solver --step Bitboard --lang rust resources/Test_L3_R1        -- $PWD/target/release/c4solver --step Bitboard
dune exec c4solver -- bench external-solver --step Bitboard --lang rust resources/Test_L2_R1        -- $PWD/target/release/c4solver --step Bitboard
dune exec c4solver -- bench external-solver --step Bitboard --lang rust resources/Test_L2_R2        -- $PWD/target/release/c4solver --step Bitboard
dune exec c4solver -- bench external-solver --step Bitboard --lang rust resources/Test_L3_R1 --weak -- $PWD/target/release/c4solver --step Bitboard --weak
dune exec c4solver -- bench external-solver --step Bitboard --lang rust resources/Test_L2_R1 --weak -- $PWD/target/release/c4solver --step Bitboard --weak
dune exec c4solver -- bench external-solver --step Bitboard --lang rust resources/Test_L2_R2 --weak -- $PWD/target/release/c4solver --step Bitboard --weak
