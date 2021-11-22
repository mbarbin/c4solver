open! Core

let do_ansi f = if ANSITerminal.isatty.contents Core_unix.stdout then f ()

let run
    ~bench_db
    ~position
    ~filenames
    ~debug
    ~alpha_beta
    ~weak
    ~column_exploration_reorder
    ~with_transposition_table
  =
  let solver =
    Bench.Solver.of_params
      { position
      ; alpha_beta
      ; weak
      ; column_exploration_reorder
      ; with_transposition_table
      ; reference = false
      }
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
                  (sprintf
                     "Bench: file %S : %d / %d"
                     test_file.basename
                     index
                     number_of_lines));
            let position =
              Bench.Test_line.make_position test_line ~height:6 ~width:7 (module P)
            in
            let { Solver.measure; result } =
              if alpha_beta
              then
                Solver.negamax_alpha_beta
                  (module P)
                  position
                  ~weak
                  ~column_exploration_reorder
                  ~with_transposition_table
              else (
                if weak || column_exploration_reorder || with_transposition_table
                then
                  raise_s
                    [%sexp
                      "Solver is not available with this combination of options"
                      , [%here]
                      , { alpha_beta : bool
                        ; column_exploration_reorder : bool
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
            then incr accuracy_count;
            if debug
            then
              print_s
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
      let accuracy =
        float_of_int !accuracy_count /. float_of_int number_of_lines *. 100.
      in
      { Bench.key = { solver; test_basename = test_file.basename }
      ; result = { Bench.Result.mean; accuracy }
      })
;;
