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

module Solver = struct
  module Params = struct
    type t =
      { position : Position.t
      ; alpha_beta : bool
      ; weak : bool
      ; column_exploration_reorder : bool
      ; with_transposition_table : bool
      ; reference : bool
      }
    [@@deriving equal, sexp_of]
  end

  module Human_name = struct
    type t =
      | MinMax
      | Alpha_beta
      | Column_exploration_order
      | Bitboard
      | Transposition_table
    [@@deriving compare, equal, enumerate, sexp]

    let to_string_hum = function
      | MinMax -> "MinMax"
      | Alpha_beta -> "Alpha-beta"
      | Column_exploration_order -> "Column exploration order"
      | Bitboard -> "Bitboard"
      | Transposition_table -> "Transposition table"
    ;;
  end

  type t =
    { human_name : Human_name.t
    ; weak : bool
    ; reference : bool
    }
  [@@deriving enumerate, compare, equal, sexp]

  let to_string_hum t =
    sprintf
      "%s%s%s"
      (Human_name.to_string_hum t.human_name)
      (if t.weak then " (weak)" else "")
      (if t.reference then " - ref" else "")
  ;;

  let to_params t : Params.t =
    match t.human_name with
    | MinMax ->
      { position = Basic
      ; alpha_beta = false
      ; weak = t.weak
      ; column_exploration_reorder = false
      ; with_transposition_table = false
      ; reference = t.reference
      }
    | Alpha_beta ->
      { position = Basic
      ; alpha_beta = true
      ; weak = t.weak
      ; column_exploration_reorder = false
      ; with_transposition_table = false
      ; reference = t.reference
      }
    | Column_exploration_order ->
      { position = Basic
      ; alpha_beta = true
      ; weak = t.weak
      ; column_exploration_reorder = true
      ; with_transposition_table = false
      ; reference = t.reference
      }
    | Bitboard ->
      { position = Bitboard
      ; alpha_beta = true
      ; weak = t.weak
      ; column_exploration_reorder = true
      ; with_transposition_table = false
      ; reference = t.reference
      }
    | Transposition_table ->
      { position = Bitboard
      ; alpha_beta = true
      ; weak = t.weak
      ; column_exploration_reorder = true
      ; with_transposition_table = true
      ; reference = t.reference
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
