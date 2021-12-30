dune exec c4solver -- bench external-solver --step Alpha_beta --name rust resources/Test_L3_R1 -- $PWD/target/release/c4solver --alpha-beta true --column-exploration-reorder false
dune exec c4solver -- bench external-solver --step Alpha_beta --weak --name rust resources/Test_L3_R1 -- $PWD/target/release/c4solver --alpha-beta true --column-exploration-reorder false --weak
