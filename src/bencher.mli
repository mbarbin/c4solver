open! Core

type t

val run
  :  bench_db:Bench_db.t
  -> position:Position.t
  -> filenames:string list
  -> debug:bool
  -> accuracy_only:bool
  -> alpha_beta:bool
  -> weak:bool
  -> column_exploration_reorder:bool
  -> with_transposition_table:bool
  -> t

val to_ascii_table : t -> string
