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

let bench (module P : Position.S) ~filenames =
  let test_files = List.map filenames ~f:(fun filename -> Test_file.load_exn ~filename) in
  let headers = [ "test"; "accuracy"; "mean time"; "mean nb of pos"; "K pos / s" ] in
  let data =
    List.map test_files ~f:(fun test_file ->
        let accuracy_count = ref 0 in
        let lines = Array.length test_file.test_lines in
        let measures =
          Array.mapi test_file.test_lines ~f:(fun index test_line ->
              let position =
                Test_line.make_position test_line ~height:6 ~width:7 (module P)
              in
              let { Solver.measure; result } = Solver.negamax (module P) position in
              if result = test_line.result then incr accuracy_count;
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
        let mean = Measure.mean measures in
        let accuracy = float_of_int !accuracy_count /. float_of_int lines *. 100. in
        [ test_file.basename
        ; sprintf "%.2f%%" accuracy
        ; Time.Span.to_string_hum mean.span
        ; Int.to_string_hum mean.number_of_positions
        ; Int.to_string_hum mean.k_pos_per_s
        ])
  in
  { headers; data }
;;

let to_ascii_table t = Ascii_table.simple_list_table_string t.headers t.data
