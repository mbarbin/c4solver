open! Base

let do_ansi f = if ANSITerminal.isatty.contents Core_unix.stdout then f ()

let run ~bench_db ~filenames ~debug ~solver =
  let { Bench.Solver.Params.position
      ; alpha_beta
      ; weak
      ; column_exploration_reorder
      ; with_transposition_table
      ; iterative_deepening
      ; reference
      }
    =
    Bench.Solver.to_params solver
  in
  let (module P : Position.S) = Position.get position in
  let test_files =
    List.map filenames ~f:(fun filename -> Bench.Test_file.load_exn ~filename)
  in
  List.map test_files ~f:(fun test_file ->
    let accuracy_count = ref 0 in
    let number_of_lines = Array.length test_file.test_lines in
    let measures =
      Array.mapi test_file.test_lines ~f:(fun index test_line ->
        do_ansi (fun () ->
          ANSITerminal.move_bol ();
          ANSITerminal.print_string
            []
            (Printf.sprintf
               "Bench: file %S : %d / %d"
               test_file.basename
               index
               number_of_lines));
        let position =
          Bench.Test_line.make_position test_line ~height:6 ~width:7 (module P)
        in
        let { Solver.Result_with_measure.measure; result } =
          if alpha_beta
          then
            Solver.negamax_alpha_beta
              (module P)
              position
              ~weak
              ~column_exploration_reorder
              ~with_transposition_table
              ~iterative_deepening
          else (
            if weak
               || column_exploration_reorder
               || with_transposition_table
               || iterative_deepening
            then
              raise_s
                [%sexp
                  "Solver is not available with this combination of options"
                  , [%here]
                  , { alpha_beta : bool
                    ; column_exploration_reorder : bool
                    ; with_transposition_table : bool
                    ; iterative_deepening : bool
                    ; weak : bool
                    }];
            Solver.negamax (module P) position)
        in
        if match weak with
           | false -> result = test_line.result
           | true ->
             Ordering.equal
               (Int.compare 0 result |> Ordering.of_int)
               (Int.compare 0 test_line.result |> Ordering.of_int)
        then Int.incr accuracy_count;
        if debug
        then
          Stdio.print_s
            [%sexp
              { index : int
              ; result : int
              ; accurate = (result = test_line.result : bool)
              ; measure : Measure.t
              }];
        measure)
      |> Array.to_list
    in
    do_ansi (fun () ->
      ANSITerminal.move_bol ();
      ANSITerminal.erase Eol);
    let mean = Measure.mean measures in
    let accuracy = Int.(!accuracy_count * 100 // number_of_lines) in
    let bench =
      { Bench.key = { solver; test_basename = test_file.basename }
      ; result = { Bench.Result.mean; accuracy }
      }
    in
    Bench_db.add bench_db ~bench;
    bench)
;;

let run_external_solver ~bench_db ~command ~filenames ~debug ~solver =
  let prog, args =
    match command with
    | [] -> raise_s [%sexp "Invalid external solver command"]
    | prog :: _ -> prog, Array.of_list command
  in
  let in_channel, out_channel = Caml_unix.open_process_args prog args in
  let test_files =
    List.map filenames ~f:(fun filename -> Bench.Test_file.load_exn ~filename)
  in
  List.map test_files ~f:(fun test_file ->
    let accuracy_count = ref 0 in
    let number_of_lines = Array.length test_file.test_lines in
    let measures =
      Array.mapi test_file.test_lines ~f:(fun index test_line ->
        do_ansi (fun () ->
          ANSITerminal.move_bol ();
          ANSITerminal.print_string
            []
            (Printf.sprintf
               "Bench: file %S : %d / %d"
               test_file.basename
               index
               number_of_lines));
        Stdio.Out_channel.output_string out_channel (test_line.position ^ "\n");
        Stdio.Out_channel.flush out_channel;
        let process_result =
          Stdio.In_channel.input_line in_channel |> Option.value_exn ~here:[%here]
        in
        let position, result, nb_positions, time_in_micro_second =
          match String.split process_result ~on:' ' with
          | [ a; b; c; d ] -> a, b, c, d
          | output ->
            raise_s [%sexp "unexpected process output", [%here], (output : string list)]
        in
        assert (String.equal position test_line.position);
        let { Solver.Result_with_measure.measure; result } =
          { Solver.Result_with_measure.measure =
              { span = Mtime_extended.Span.of_us (Float.of_string time_in_micro_second)
              ; number_of_positions = Int.of_string nb_positions
              }
          ; result = Int.of_string result
          }
        in
        if match solver.Bench.Solver.weak with
           | false -> result = test_line.result
           | true ->
             Ordering.equal
               (Int.compare 0 result |> Ordering.of_int)
               (Int.compare 0 test_line.result |> Ordering.of_int)
        then Int.incr accuracy_count;
        if debug
        then
          Stdio.print_s
            [%sexp
              { index : int
              ; result : int
              ; accurate = (result = test_line.result : bool)
              ; measure : Measure.t
              }];
        measure)
      |> Array.to_list
    in
    do_ansi (fun () ->
      ANSITerminal.move_bol ();
      ANSITerminal.erase Eol);
    let mean = Measure.mean measures in
    let accuracy = Int.(!accuracy_count * 100 // number_of_lines) in
    let bench =
      { Bench.key = { solver; test_basename = test_file.basename }
      ; result = { Bench.Result.mean; accuracy }
      }
    in
    Bench_db.add bench_db ~bench;
    bench)
;;
