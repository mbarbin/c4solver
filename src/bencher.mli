open! Base

val run
  :  bench_db:Bench_db.t
  -> filenames:string list
  -> debug:bool
  -> solver:Bench.Solver.t
  -> Bench.t list

val run_external_solver
  :  bench_db:Bench_db.t
  -> command:string list
  -> filenames:string list
  -> debug:bool
  -> solver:Bench.Solver.t
  -> Bench.t list
