dune exec c4solver -- bench external-solver --human-name Column_exploration_order --name rust resources/Test_L3_R1 -- $PWD/target/release/c4solver --alpha-beta true --column-exploration-reorder true

dune exec c4solver -- bench external-solver --human-name Column_exploration_order --name rust resources/Test_L2_R1 -- $PWD/target/release/c4solver --alpha-beta true --column-exploration-reorder true

dune exec c4solver -- bench external-solver --human-name Column_exploration_order --weak --name rust resources/Test_L3_R1 -- $PWD/target/release/c4solver --alpha-beta true --column-exploration-reorder true --weak

dune exec c4solver -- bench external-solver --human-name Column_exploration_order --weak --name rust resources/Test_L2_R1 -- $PWD/target/release/c4solver --alpha-beta true --column-exploration-reorder true --weak

