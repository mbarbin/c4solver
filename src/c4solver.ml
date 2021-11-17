open! Core
module Bencher = Bencher
module Measure = Measure
module Position = Position
module Solver = Solver

let bench_cmd =
  Command.basic
    ~summary:"bench solver"
    (let%map_open.Command filenames =
       anon (Command.Anons.non_empty_sequence_as_list ("FILE" %: string))
     and height = return 6
     and width = return 7
     and position = return (module Position.Basic : Position.S) in
     fun () ->
       let bench = Bencher.bench position ~filenames in
       print_endline (Bencher.to_ascii_table bench))
;;

let main = Command.group ~summary:"c4 solver" [ "bench", bench_cmd ]
