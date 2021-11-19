open! Core

module Test_line = struct
  type t =
    { position : string
    ; result : int
    }
  [@@deriving sexp_of]

  let parse_exn str =
    let position, result = String.lsplit2 ~on:' ' str |> Option.value_exn ~here:[%here] in
    let result = Int.of_string result in
    { position; result }
  ;;

  let make_position (type p) t ~height ~width (module P : Position.S with type t = p) =
    let p = P.create ~height ~width in
    String.iteri t.position ~f:(fun index char ->
        let column = Char.to_int char - Char.to_int '1' in
        if column < 0
           || column >= width
           || (not (P.can_play p ~column))
           || P.is_winning_move p ~column
        then raise_s [%sexp [%here], "invalid move", { t : t; index : int; column : int }]
        else P.play p ~column);
    P.copy p
  ;;
end

module Test_file = struct
  type t =
    { basename : string
    ; test_lines : Test_line.t Array.t
    }

  let load_exn ~filename =
    let lines = Stdio.In_channel.read_lines filename in
    let basename = Filename.basename filename in
    { basename; test_lines = Array.of_list lines |> Array.map ~f:Test_line.parse_exn }
  ;;
end

type t =
  { headers : string list
  ; data : string list list
  }

let do_ansi f = if ANSITerminal.isatty.contents Core_unix.stdout then f ()

let run
    ~bench_db
    ~position
    ~filenames
    ~debug
    ~accuracy_only
    ~alpha_beta
    ~weak
    ~column_exploration_reorder
    ~with_transposition_table
  =
  let solver =
    Bench_db.Solver.of_params
      { position
      ; alpha_beta
      ; weak
      ; column_exploration_reorder
      ; with_transposition_table
      ; reference = false
      }
  in
  let (module P : Position.S) = Position.get position in
  let test_files = List.map filenames ~f:(fun filename -> Test_file.load_exn ~filename) in
  let headers =
    [ true, "test"
    ; true, "accuracy"
    ; not accuracy_only, "mean time"
    ; true, "mean nb of pos"
    ; not accuracy_only, "K pos / s"
    ]
    |> List.filter_map ~f:(fun (t, v) -> Option.some_if t v)
  in
  let data =
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
                Test_line.make_position test_line ~height:6 ~width:7 (module P)
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
        let key = { Bench_db.Key.solver; test_basename = test_file.basename } in
        let result = { Bench_db.Result.mean; accuracy } in
        Bench_db.add bench_db ~key ~result;
        [ true, test_file.basename
        ; true, sprintf "%.2f%%" accuracy
        ; not accuracy_only, Time.Span.to_string_hum mean.span
        ; true, Int.to_string_hum mean.number_of_positions
        ; not accuracy_only, Int.to_string_hum mean.k_pos_per_s
        ]
        |> List.filter_map ~f:(fun (t, v) -> Option.some_if t v))
  in
  { headers; data }
;;

let to_ascii_table t = Ascii_table.simple_list_table_string t.headers t.data
