open! Core

(** A bench db is a local file where we store bench results as we
   gather them using the [bench run] command. The motivation for
   storing them is so that we can show them all together in nice
   tables, and avoid re-running benches that we have already run too
   many times unintentionally. *)

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
  [@@deriving sexp]
end

(* References entries - from [http://blog.gamesolver.org/solving-connect-four/]. *)
let reference_entries =
  let minmax = { Solver.human_name = MinMax; weak = false; reference = true } in
  let alpha_beta_strong =
    { Solver.human_name = Alpha_beta; weak = false; reference = true }
  in
  let alpha_beta_weak =
    { Solver.human_name = Alpha_beta; weak = true; reference = true }
  in
  let ceo_strong =
    { Solver.human_name = Column_exploration_order; weak = false; reference = true }
  in
  let ceo_weak =
    { Solver.human_name = Column_exploration_order; weak = true; reference = true }
  in
  let bit_strong = { Solver.human_name = Bitboard; weak = false; reference = true } in
  let bit_weak = { Solver.human_name = Bitboard; weak = true; reference = true } in
  let trans_strong =
    { Solver.human_name = Transposition_table; weak = false; reference = true }
  in
  let trans_weak =
    { Solver.human_name = Transposition_table; weak = true; reference = true }
  in
  (* MinMax. *)
  [ ( { Key.solver = minmax; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time.Span.of_us 790.28
          ; number_of_positions = 11_024
          ; k_pos_per_s = 13_950
          }
      ; accuracy = 100.
      } )
    (* Alpha-beta. *)
  ; ( { Key.solver = alpha_beta_strong; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time.Span.of_us 69.62; number_of_positions = 284; k_pos_per_s = 4_074 }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = alpha_beta_strong; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time.Span.of_sec 4.54
          ; number_of_positions = 54_236_700
          ; k_pos_per_s = 11_940
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = alpha_beta_strong; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time.Span.of_sec 38.7
          ; number_of_positions = 453_614_000
          ; k_pos_per_s = 11_725
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = alpha_beta_weak; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time.Span.of_us 52.0; number_of_positions = 223; k_pos_per_s = 4_284 }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = alpha_beta_weak; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time.Span.of_sec 3.28
          ; number_of_positions = 41_401_200
          ; k_pos_per_s = 12_638
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = alpha_beta_weak; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time.Span.of_sec 24.5
          ; number_of_positions = 308_114_000
          ; k_pos_per_s = 12_548
          }
      ; accuracy = 100.
      } )
    (* Column exploration order. *)
  ; ( { Key.solver = ceo_strong; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time.Span.of_us 40.86; number_of_positions = 140; k_pos_per_s = 3_417 }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = ceo_strong; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time.Span.of_ms 189.1
          ; number_of_positions = 2_081_790
          ; k_pos_per_s = 11_009
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = ceo_strong; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time.Span.of_sec 3.48
          ; number_of_positions = 40_396_700
          ; k_pos_per_s = 11_594
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = ceo_weak; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time.Span.of_us 31.16; number_of_positions = 107; k_pos_per_s = 3_438 }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = ceo_weak; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time.Span.of_ms 77.13
          ; number_of_positions = 927_943
          ; k_pos_per_s = 12_031
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = ceo_weak; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time.Span.of_sec 1.949
          ; number_of_positions = 23_685_400
          ; k_pos_per_s = 12_153
          }
      ; accuracy = 100.
      } )
    (* Bitboard. *)
  ; ( { Key.solver = bit_strong; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time.Span.of_us 8.55; number_of_positions = 140; k_pos_per_s = 16_334 }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = bit_strong; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time.Span.of_ms 33.31
          ; number_of_positions = 2_081_790
          ; k_pos_per_s = 62_504
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = bit_strong; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time.Span.of_ms 644.
          ; number_of_positions = 40_396_700
          ; k_pos_per_s = 62_727
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = bit_weak; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time.Span.of_us 6.708
          ; number_of_positions = 107
          ; k_pos_per_s = 15_973
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = bit_weak; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time.Span.of_ms 14.69
          ; number_of_positions = 927_943
          ; k_pos_per_s = 63_149
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = bit_weak; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time.Span.of_ms 370.3
          ; number_of_positions = 23_685_400
          ; k_pos_per_s = 63_968
          }
      ; accuracy = 100.
      } )
    (* Transposition table. *)
  ; ( { Key.solver = trans_strong; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time.Span.of_us 6.531; number_of_positions = 93; k_pos_per_s = 14_220 }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_strong; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time.Span.of_ms 5.594
          ; number_of_positions = 207_900
          ; k_pos_per_s = 37_170
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_strong; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time.Span.of_ms 52.45
          ; number_of_positions = 1_731_000
          ; k_pos_per_s = 33_000
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_strong; test_basename = "Test_L1_R1" }
    , { Result.mean =
          { span = Time.Span.of_sec 4.727
          ; number_of_positions = 156_400_000
          ; k_pos_per_s = 33_090
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_strong; test_basename = "Test_L1_R2" }
    , { Result.mean =
          { span = Time.Span.of_sec 8.2
          ; number_of_positions = 306_100_000
          ; k_pos_per_s = 37_330
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_weak; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time.Span.of_us 5.155; number_of_positions = 67; k_pos_per_s = 13_320 }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_weak; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time.Span.of_ms 1.072
          ; number_of_positions = 28_750
          ; k_pos_per_s = 26_830
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_weak; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time.Span.of_ms 23.79
          ; number_of_positions = 752_300
          ; k_pos_per_s = 31_620
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_weak; test_basename = "Test_L1_R1" }
    , { Result.mean =
          { span = Time.Span.of_sec 1.610
          ; number_of_positions = 52_840_000
          ; k_pos_per_s = 32_830
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_weak; test_basename = "Test_L1_R2" }
    , { Result.mean =
          { span = Time.Span.of_sec 1.762
          ; number_of_positions = 63_930_000
          ; k_pos_per_s = 36_280
          }
      ; accuracy = 100.
      } )
  ]
;;

type entries = Result.t Map.M(Key).t [@@deriving sexp]

type t =
  { filename : string
  ; mutable entries : entries
  }

let load_or_init ~filename =
  let entries =
    match Sexp.load_sexp filename with
    | exception _ -> Map.empty (module Key)
    | sexp -> entries_of_sexp sexp
  in
  let entries =
    List.fold reference_entries ~init:entries ~f:(fun acc (key, data) ->
        Map.set acc ~key ~data)
  in
  { filename; entries }
;;

let mem t ~key = Map.mem t.entries key
let save t = Sexp.save_hum t.filename (sexp_of_entries t.entries)

let add t ~key ~result =
  let t = load_or_init ~filename:t.filename in
  t.entries <- Map.set t.entries ~key ~data:result;
  save t
;;

let to_ascii_table t =
  let columns =
    let f ((key : Key.t), (result : Result.t)) = key, result in
    let dim (key : Key.t) styles =
      if key.solver.reference then `Dim :: styles else styles
    in
    [ Ascii_table.Column.create_attr "solver" ~align:Left (fun c ->
          let key, _ = f c in
          dim key [], Solver.to_string_hum key.solver)
    ; Ascii_table.Column.create_attr "test" ~align:Left (fun c ->
          let key, _ = f c in
          dim key [], key.test_basename)
    ; Ascii_table.Column.create_attr "accuracy" ~align:Right (fun c ->
          let key, result = f c in
          dim key [], sprintf "%.2f%%" result.accuracy)
    ; Ascii_table.Column.create_attr "mean time" ~align:Right (fun c ->
          let key, result = f c in
          dim key [], Time.Span.to_string_hum result.mean.span)
    ; Ascii_table.Column.create_attr "mean nb of pos" ~align:Right (fun c ->
          let key, result = f c in
          let styles =
            if key.solver.reference
            then []
            else (
              let ref = { key with solver = { key.solver with reference = true } } in
              match Map.find t.entries ref with
              | None -> []
              | Some ref_result ->
                if ref_result.mean.number_of_positions = result.mean.number_of_positions
                then [ `Green ]
                else [ `Yellow ])
          in
          dim key styles, Int.to_string_hum result.mean.number_of_positions)
    ; Ascii_table.Column.create_attr "K pos / s" ~align:Right (fun c ->
          let key, result = f c in
          dim key [], Int.to_string_hum result.mean.k_pos_per_s)
    ]
  in
  let data = Map.to_alist t.entries in
  Ascii_table.to_string ~limit_width_to:250 columns data
;;
