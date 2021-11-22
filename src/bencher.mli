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
