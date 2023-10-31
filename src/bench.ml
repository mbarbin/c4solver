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
    let lines = In_channel.read_lines filename in
    let basename = Filename_base.basename filename in
    { basename; test_lines = Array.of_list lines |> Array.map ~f:Test_line.parse_exn }
  ;;
end

module Solver = struct
  module Lang = struct
    type t =
      | Cpp
      | Ocaml
      | Rust
    [@@deriving enumerate, compare, equal, sexp]

    let to_string_hum = function
      | Cpp -> "c++"
      | Ocaml -> "ocaml"
      | Rust -> "rust"
    ;;
  end

  module Params = struct
    type t =
      { position : Position.t
      ; alpha_beta : bool
      ; weak : bool
      ; column_exploration_reorder : bool
      ; with_transposition_table : bool
      ; iterative_deepening : bool
      ; reference : bool
      ; lang : Lang.t
      }
    [@@deriving equal, sexp_of]
  end

  type t =
    { step : Step.t
    ; weak : bool
    ; reference : bool
    ; lang : Lang.t
    }
  [@@deriving enumerate, compare, equal, sexp]

  let to_string_hum t =
    Printf.sprintf
      "%s%s %s%s"
      (Step.to_string_hum t.step)
      (if t.weak then " (weak)" else "")
      (Lang.to_string_hum t.lang)
      (if t.reference then " - ref" else "")
  ;;

  let to_params t : Params.t =
    match t.step with
    | MinMax ->
      { position = Basic
      ; alpha_beta = false
      ; weak = t.weak
      ; column_exploration_reorder = false
      ; with_transposition_table = false
      ; iterative_deepening = false
      ; reference = t.reference
      ; lang = t.lang
      }
    | Alpha_beta ->
      { position = Basic
      ; alpha_beta = true
      ; weak = t.weak
      ; column_exploration_reorder = false
      ; with_transposition_table = false
      ; iterative_deepening = false
      ; reference = t.reference
      ; lang = t.lang
      }
    | Column_exploration_order ->
      { position = Basic
      ; alpha_beta = true
      ; weak = t.weak
      ; column_exploration_reorder = true
      ; with_transposition_table = false
      ; iterative_deepening = false
      ; reference = t.reference
      ; lang = t.lang
      }
    | Bitboard ->
      { position = Bitboard
      ; alpha_beta = true
      ; weak = t.weak
      ; column_exploration_reorder = true
      ; with_transposition_table = false
      ; iterative_deepening = false
      ; reference = t.reference
      ; lang = t.lang
      }
    | Transposition_table ->
      { position = Bitboard
      ; alpha_beta = true
      ; weak = t.weak
      ; column_exploration_reorder = true
      ; with_transposition_table = true
      ; iterative_deepening = false
      ; reference = t.reference
      ; lang = t.lang
      }
    | Iterative_deepening ->
      { position = Bitboard
      ; alpha_beta = true
      ; weak = t.weak
      ; column_exploration_reorder = true
      ; with_transposition_table = true
      ; iterative_deepening = true
      ; reference = t.reference
      ; lang = t.lang
      }
  ;;

  let of_params (p : Params.t) =
    match List.find all ~f:(fun t -> Params.equal p (to_params t)) with
    | Some t -> t
    | None -> raise_s [%sexp "unsupported parameters", [%here], (p : Params.t)]
  ;;

  let%expect_test "roundtrip" =
    List.iter all ~f:(fun t ->
      let p = t |> to_params in
      let t' = p |> of_params in
      if not (equal t t')
      then
        print_s
          [%sexp "Value does not roundtrip", [%here], { t : t; t' : t; p : Params.t }]);
    [%expect {||}]
  ;;
end

module Key = struct
  module Test_basename = struct
    module Key = struct
      type t =
        | Int of int
        | String of string
      [@@deriving equal, compare]
    end

    type t = string [@@deriving equal, sexp]

    let to_key : t -> Key.t = function
      | "Test_L3_R1" -> Int 0
      | "Test_L2_R1" -> Int 1
      | "Test_L2_R2" -> Int 2
      | "Test_L1_R1" -> Int 3
      | "Test_L1_R2" -> Int 4
      | "Test_L1_R3" -> Int 5
      | str -> String str
    ;;

    let compare a b = Key.compare (to_key a) (to_key b)
  end

  module T = struct
    type t =
      { solver : Solver.t
      ; test_basename : Test_basename.t
      }
    [@@deriving compare, equal, sexp]
  end

  include T
  include Comparator.Make (T)
end

module Result = struct
  type t =
    { mean : Measure.Mean.t
    ; accuracy : float
    }
  [@@deriving compare, equal, sexp]
end

type t =
  { key : Key.t
  ; result : Result.t
  }
[@@deriving compare, equal, sexp]

let to_ascii_table
  ?(entries = (Map.empty (module Key) : Result.t Map.M(Key).t))
  ?(accuracy_only = false)
  ts
  =
  let isatty = ANSITerminal.isatty.contents Core_unix.stdout in
  let columns =
    let dim (t : t) styles =
      let styles = if t.key.solver.reference then `Dim :: styles else styles in
      if isatty then styles else []
    in
    [ [ Ascii_table.Column.create_attr "solver" ~align:Left (fun t ->
          dim t [], Solver.to_string_hum t.key.solver)
      ; Ascii_table.Column.create_attr "test" ~align:Left (fun t ->
          dim t [], t.key.test_basename)
      ; Ascii_table.Column.create_attr "accuracy" ~align:Right (fun t ->
          dim t [], Printf.sprintf "%.2f%%" t.result.accuracy)
      ]
    ; (if accuracy_only
       then []
       else
         [ Ascii_table.Column.create_attr "mean time" ~align:Right (fun t ->
             dim t [], Mtime_extended.Span.to_string_hum t.result.mean.span)
         ])
    ; [ Ascii_table.Column.create_attr "mean nb of pos" ~align:Right (fun t ->
          let { key; result } = t in
          let styles =
            if key.solver.reference
            then []
            else (
              let ref =
                { key with solver = { key.solver with reference = true; lang = Cpp } }
              in
              match Map.find entries ref with
              | None -> []
              | Some ref_result ->
                if ref_result.mean.number_of_positions = result.mean.number_of_positions
                then [ `Green ]
                else [ `Yellow ])
          in
          dim t styles, Int.to_string_hum result.mean.number_of_positions)
      ]
    ; (if accuracy_only
       then []
       else
         [ Ascii_table.Column.create_attr "K pos / s" ~align:Right (fun t ->
             dim t [], Int.to_string_hum t.result.mean.k_pos_per_s)
         ])
    ]
    |> List.concat
  in
  Ascii_table.to_string ~limit_width_to:250 columns ts
;;
