dune exec c4solver -- bench external-solver --human-name Alpha_beta --name rust resources/Test_L3_R1 -- $PWD/target/release/c4solver --alpha-beta true
dune exec c4solver -- bench external-solver --human-name Alpha_beta --weak --name rust resources/Test_L3_R1 -- $PWD/target/release/c4solver --alpha-beta true --weak
