open! Core
module Bench = Bench
module Bencher = Bencher
module Measure = Measure
module Position = Position
module Solver = Solver

let bench_db_default_filename = ".bench-db.sexp"

let bench_run_cmd =
  Command.basic
    ~summary:"run a benchmark"
    (let%map_open.Command filenames = anon (non_empty_sequence_as_list ("FILE" %: string))
     and height = return 6
     and width = return 7
     and position =
       flag
         "--position"
         (optional_with_default
            Position.Basic
            (Arg_type.enumerated_sexpable ~case_sensitive:false (module Position)))
         ~doc:" choose position implementation"
     and alpha_beta =
       flag
         "--alpha-beta"
         (optional_with_default true bool)
         ~doc:"bool enable alpha-beta prunning (default true)"
     and column_exploration_reorder =
       flag
         "--column-exploration-reorder"
         (optional_with_default true bool)
         ~doc:"bool explore with center columns first (default true)"
     and with_transposition_table =
       flag
         "--with-transposition-table"
         (optional_with_default false bool)
         ~doc:"bool use a transposition table (default false)"
     and iterative_deepening =
       flag
         "--iterative-deepening"
         (optional_with_default false bool)
         ~doc:"bool enable iterative deepening (default false)"
     and weak = flag "--weak" no_arg ~doc:" enable weak solving (1:Win/-1:Lose/0:Draw)"
     and accuracy_only = flag "--accuracy-only" no_arg ~doc:" print only accuracy info"
     and debug = flag "--debug" no_arg ~doc:" print debug info" in
     fun () ->
       let bench_db = Bench_db.load_or_init ~filename:bench_db_default_filename in
       let benches =
         Bencher.run
           ~bench_db
           ~position
           ~filenames
           ~debug
           ~alpha_beta
           ~weak
           ~column_exploration_reorder
           ~with_transposition_table
           ~iterative_deepening
       in
       print_endline (Bench.to_ascii_table ~accuracy_only benches))
;;

let bench_run_external_cmd =
  Command.basic
    ~summary:"run an external solver"
    (let%map_open.Command filenames = anon (non_empty_sequence_as_list ("FILE" %: string))
     and height = return 6
     and width = return 7
     and weak = flag "--weak" no_arg ~doc:" enable weak solving (1:Win/-1:Lose/0:Draw)"
     and reference = flag "--reference" no_arg ~doc:" solver is a reference"
     and human_name =
       flag
         "--human-name"
         (required (Arg_type.enumerated_sexpable (module Bench.Solver.Human_name)))
         ~doc:"sexp solver human-name"
     and solver =
       flag "--name" (required string) ~doc:"name external solver shortname (language)"
     and accuracy_only = flag "--accuracy-only" no_arg ~doc:" print only accuracy info"
     and debug = flag "--debug" no_arg ~doc:" print debug info"
     and command =
       match%map.Command flag "--" escape ~doc:" solver command" with
       | Some command -> command
       | None -> raise_s [%sexp "external solver command is mandatory"]
     in
     fun () ->
       let solver = { Bench.Solver.human_name; weak; reference; ext = Some solver } in
       let bench_db = Bench_db.load_or_init ~filename:bench_db_default_filename in
       let benches =
         Bencher.run_external_solver ~bench_db ~command ~solver ~weak ~debug ~filenames
       in
       print_endline (Bench.to_ascii_table ~accuracy_only benches))
;;

let bench_show_cmd =
  Command.basic
    ~summary:"show saved benchmark"
    (let%map_open.Command filename =
       anon (maybe_with_default bench_db_default_filename ("FILE" %: string))
     in
     fun () ->
       let bench_db = Bench_db.load_or_init ~filename in
       print_string (Bench_db.to_ascii_table bench_db))
;;

let bench_cmd =
  Command.group
    ~summary:"bench commands"
    [ "external-solver", bench_run_external_cmd
    ; "show", bench_show_cmd
    ; "run", bench_run_cmd
    ]
;;

let main = Command.group ~summary:"c4 solver" [ "bench", bench_cmd ]
