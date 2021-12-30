dune exec c4solver -- bench run resources/Test_L3_R1 --step Transposition_table
dune exec c4solver -- bench run resources/Test_L2_R1 --step Transposition_table
dune exec c4solver -- bench run resources/Test_L2_R2 --step Transposition_table
dune exec c4solver -- bench run resources/Test_L3_R1 --step Transposition_table --weak
dune exec c4solver -- bench run resources/Test_L2_R1 --step Transposition_table --weak
dune exec c4solver -- bench run resources/Test_L2_R2 --step Transposition_table --weak
