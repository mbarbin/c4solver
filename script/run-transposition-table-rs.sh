dune exec c4solver -- bench external-solver --step Transposition_table --lang rust resources/Test_L3_R1        -- $PWD/target/release/c4solver --step TranspositionTable
dune exec c4solver -- bench external-solver --step Transposition_table --lang rust resources/Test_L2_R1        -- $PWD/target/release/c4solver --step TranspositionTable
dune exec c4solver -- bench external-solver --step Transposition_table --lang rust resources/Test_L2_R2        -- $PWD/target/release/c4solver --step TranspositionTable
dune exec c4solver -- bench external-solver --step Transposition_table --lang rust resources/Test_L3_R1 --weak -- $PWD/target/release/c4solver --step TranspositionTable --weak
dune exec c4solver -- bench external-solver --step Transposition_table --lang rust resources/Test_L2_R1 --weak -- $PWD/target/release/c4solver --step TranspositionTable --weak
dune exec c4solver -- bench external-solver --step Transposition_table --lang rust resources/Test_L2_R2 --weak -- $PWD/target/release/c4solver --step TranspositionTable --weak
