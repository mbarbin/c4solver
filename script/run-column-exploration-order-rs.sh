dune exec c4solver -- bench external-solver --step Column_exploration_order --lang rust resources/Test_L3_R1        -- $PWD/target/release/c4solver --step ColumnExplorationOrder
dune exec c4solver -- bench external-solver --step Column_exploration_order --lang rust resources/Test_L2_R1        -- $PWD/target/release/c4solver --step ColumnExplorationOrder
dune exec c4solver -- bench external-solver --step Column_exploration_order --lang rust resources/Test_L3_R1 --weak -- $PWD/target/release/c4solver --step ColumnExplorationOrder --weak
dune exec c4solver -- bench external-solver --step Column_exploration_order --lang rust resources/Test_L2_R1 --weak -- $PWD/target/release/c4solver --step ColumnExplorationOrder --weak
