open! Core
module Bencher = Bencher
module Measure = Measure
module Position = Position
module Solver = Solver

let bench_cmd =
  Command.basic
    ~summary:"bench solver"
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
       >>| Position.get
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
     and weak = flag "--weak" no_arg ~doc:" enable weak solving (1:Win/-1:Lose/0:Draw)"
     and accuracy_only = flag "--accuracy-only" no_arg ~doc:" print only accuracy info"
     and debug = flag "--debug" no_arg ~doc:" print debug info" in
     fun () ->
       let bench =
         Bencher.bench
           position
           ~filenames
           ~debug
           ~accuracy_only
           ~alpha_beta
           ~weak
           ~column_exploration_reorder
       in
       print_endline (Bencher.to_ascii_table bench))
;;

let main = Command.group ~summary:"c4 solver" [ "bench", bench_cmd ]
