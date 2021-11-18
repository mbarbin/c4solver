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
     and position = return (module Position.Basic : Position.S)
     and alpha_beta =
       flag
         "--alpha-beta"
         (optional_with_default true bool)
         ~doc:" enable alpha-beta prunning (default true)"
     and weak = flag "--weak" no_arg ~doc:" enable weak solving (1:Win/-1:Lose/0:Draw)"
     and accuracy_only = flag "--accuracy-only" no_arg ~doc:" print only accuracy info"
     and debug = flag "--debug" no_arg ~doc:" print debug info" in
     fun () ->
       let bench =
         Bencher.bench position ~filenames ~debug ~accuracy_only ~alpha_beta ~weak
       in
       print_endline (Bencher.to_ascii_table bench))
;;

let main = Command.group ~summary:"c4 solver" [ "bench", bench_cmd ]
