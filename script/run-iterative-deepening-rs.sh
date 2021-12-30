dune exec c4solver -- bench external-solver --step Iterative_deepening --lang rust resources/Test_L3_R1        -- $PWD/target/release/c4solver --step IterativeDeepening
dune exec c4solver -- bench external-solver --step Iterative_deepening --lang rust resources/Test_L2_R1        -- $PWD/target/release/c4solver --step IterativeDeepening
dune exec c4solver -- bench external-solver --step Iterative_deepening --lang rust resources/Test_L2_R2        -- $PWD/target/release/c4solver --step IterativeDeepening
dune exec c4solver -- bench external-solver --step Iterative_deepening --lang rust resources/Test_L1_R1        -- $PWD/target/release/c4solver --step IterativeDeepening
dune exec c4solver -- bench external-solver --step Iterative_deepening --lang rust resources/Test_L3_R1 --weak -- $PWD/target/release/c4solver --step IterativeDeepening --weak
dune exec c4solver -- bench external-solver --step Iterative_deepening --lang rust resources/Test_L2_R1 --weak -- $PWD/target/release/c4solver --step IterativeDeepening --weak
dune exec c4solver -- bench external-solver --step Iterative_deepening --lang rust resources/Test_L2_R2 --weak -- $PWD/target/release/c4solver --step IterativeDeepening --weak
dune exec c4solver -- bench external-solver --step Iterative_deepening --lang rust resources/Test_L1_R1 --weak -- $PWD/target/release/c4solver --step IterativeDeepening --weak
