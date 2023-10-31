open! Stdio
module Bench = Bench
module Bench_db = Bench_db
module Bencher = Bencher
module Gen_scripts = Gen_scripts
module Measure = Measure
module Position = Position
module Solver = Solver
module Step = Step

let bench_db_default_filename = ".bench-db.sexp"

let bench_run_cmd =
  Command.basic
    ~summary:"run a benchmark"
    (let%map_open.Command filenames = anon (non_empty_sequence_as_list ("FILE" %: string))
     and weak = flag "--weak" no_arg ~doc:" enable weak solving (1:Win/-1:Lose/0:Draw)"
     and accuracy_only = flag "--accuracy-only" no_arg ~doc:" print only accuracy info"
     and step =
       flag
         "--step"
         (required (Arg_type.enumerated_sexpable (module Step)))
         ~doc:"sexp solver step"
     and debug = flag "--debug" no_arg ~doc:" print debug info" in
     fun () ->
       let solver = { Bench.Solver.step; weak; reference = false; lang = Ocaml } in
       let bench_db = Bench_db.load_or_init ~filename:bench_db_default_filename in
       let benches = Bencher.run ~bench_db ~filenames ~debug ~solver in
       print_endline (Bench.to_ascii_table ~accuracy_only benches))
;;

let bench_run_external_cmd =
  Command.basic
    ~summary:"run an external solver"
    (let%map_open.Command filenames = anon (non_empty_sequence_as_list ("FILE" %: string))
     and weak = flag "--weak" no_arg ~doc:" enable weak solving (1:Win/-1:Lose/0:Draw)"
     and reference = flag "--reference" no_arg ~doc:" solver is a reference"
     and step =
       flag
         "--step"
         (required (Arg_type.enumerated_sexpable (module Step)))
         ~doc:"sexp solver step"
     and lang =
       flag
         "--lang"
         (required
            (Arg_type.enumerated_sexpable
               (module Bench.Solver.Lang)
               ~case_sensitive:false))
         ~doc:"name external solver language"
     and accuracy_only = flag "--accuracy-only" no_arg ~doc:" print only accuracy info"
     and debug = flag "--debug" no_arg ~doc:" print debug info"
     and command =
       match%map.Command flag "--" escape ~doc:" solver command" with
       | Some command -> command
       | None -> raise_s [%sexp "external solver command is mandatory"]
     in
     fun () ->
       let solver = { Bench.Solver.step; weak; reference; lang } in
       let bench_db = Bench_db.load_or_init ~filename:bench_db_default_filename in
       let benches =
         Bencher.run_external_solver ~bench_db ~command ~filenames ~debug ~solver
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

let main =
  Command.group
    ~summary:"c4 solver"
    [ "bench", bench_cmd; "gen-scripts", Gen_scripts.main ]
;;
