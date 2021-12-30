dune exec c4solver -- bench external-solver --step Alpha_beta --lang rust resources/Test_L3_R1        -- $PWD/target/release/c4solver --step AlphaBeta
dune exec c4solver -- bench external-solver --step Alpha_beta --lang rust resources/Test_L3_R1 --weak -- $PWD/target/release/c4solver --step AlphaBeta --weak
