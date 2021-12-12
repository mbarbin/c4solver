open! Core

val run
  :  bench_db:Bench_db.t
  -> position:Position.t
  -> filenames:string list
  -> debug:bool
  -> alpha_beta:bool
  -> weak:bool
  -> column_exploration_reorder:bool
  -> with_transposition_table:bool
  -> Bench.t list

val run_external_solver
  :  command:string list
  -> solver:Bench.Solver.t
  -> weak:bool
  -> debug:bool
  -> filenames:string list
  -> Bench.t list
