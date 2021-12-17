open! Core

(** A bench db is a local file where we store bench results as we
   gather them using the [bench run] command. The motivation for
   storing them is so that we can show them all together in nice
   tables, and avoid re-running benches that we have already run too
   many times unintentionally. *)
open! Bench

(* References entries - from [http://blog.gamesolver.org/solving-connect-four/]. *)
let reference_entries =
  let ext = None in
  let minmax = { Solver.human_name = MinMax; weak = false; reference = true; ext } in
  let alpha_beta_strong =
    { Solver.human_name = Alpha_beta; weak = false; reference = true; ext }
  in
  let alpha_beta_weak =
    { Solver.human_name = Alpha_beta; weak = true; reference = true; ext }
  in
  let ceo_strong =
    { Solver.human_name = Column_exploration_order; weak = false; reference = true; ext }
  in
  let ceo_weak =
    { Solver.human_name = Column_exploration_order; weak = true; reference = true; ext }
  in
  let bit_strong =
    { Solver.human_name = Bitboard; weak = false; reference = true; ext }
  in
  let bit_weak = { Solver.human_name = Bitboard; weak = true; reference = true; ext } in
  let trans_strong =
    { Solver.human_name = Transposition_table; weak = false; reference = true; ext }
  in
  let trans_weak =
    { Solver.human_name = Transposition_table; weak = true; reference = true; ext }
  in
  (* MinMax. *)
  [ ( { Key.solver = minmax; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_us 790.28
          ; number_of_positions = 11_024
          ; k_pos_per_s = 13_950
          }
      ; accuracy = 100.
      } )
    (* Alpha-beta. *)
  ; ( { Key.solver = alpha_beta_strong; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_us 69.62
          ; number_of_positions = 284
          ; k_pos_per_s = 4_074
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = alpha_beta_strong; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_sec 4.54
          ; number_of_positions = 54_236_700
          ; k_pos_per_s = 11_940
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = alpha_beta_strong; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time_ns.Span.of_sec 38.7
          ; number_of_positions = 453_614_000
          ; k_pos_per_s = 11_725
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = alpha_beta_weak; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_us 52.0
          ; number_of_positions = 223
          ; k_pos_per_s = 4_284
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = alpha_beta_weak; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_sec 3.28
          ; number_of_positions = 41_401_200
          ; k_pos_per_s = 12_638
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = alpha_beta_weak; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time_ns.Span.of_sec 24.5
          ; number_of_positions = 308_114_000
          ; k_pos_per_s = 12_548
          }
      ; accuracy = 100.
      } )
    (* Column exploration order. *)
  ; ( { Key.solver = ceo_strong; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_us 40.86
          ; number_of_positions = 140
          ; k_pos_per_s = 3_417
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = ceo_strong; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_ms 189.1
          ; number_of_positions = 2_081_790
          ; k_pos_per_s = 11_009
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = ceo_strong; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time_ns.Span.of_sec 3.48
          ; number_of_positions = 40_396_700
          ; k_pos_per_s = 11_594
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = ceo_weak; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_us 31.16
          ; number_of_positions = 107
          ; k_pos_per_s = 3_438
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = ceo_weak; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_ms 77.13
          ; number_of_positions = 927_943
          ; k_pos_per_s = 12_031
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = ceo_weak; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time_ns.Span.of_sec 1.949
          ; number_of_positions = 23_685_400
          ; k_pos_per_s = 12_153
          }
      ; accuracy = 100.
      } )
    (* Bitboard. *)
  ; ( { Key.solver = bit_strong; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_us 8.55
          ; number_of_positions = 140
          ; k_pos_per_s = 16_334
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = bit_strong; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_ms 33.31
          ; number_of_positions = 2_081_790
          ; k_pos_per_s = 62_504
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = bit_strong; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time_ns.Span.of_ms 644.
          ; number_of_positions = 40_396_700
          ; k_pos_per_s = 62_727
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = bit_weak; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_us 6.708
          ; number_of_positions = 107
          ; k_pos_per_s = 15_973
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = bit_weak; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_ms 14.69
          ; number_of_positions = 927_943
          ; k_pos_per_s = 63_149
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = bit_weak; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time_ns.Span.of_ms 370.3
          ; number_of_positions = 23_685_400
          ; k_pos_per_s = 63_968
          }
      ; accuracy = 100.
      } )
    (* Transposition table. *)
  ; ( { Key.solver = trans_strong; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_us 6.531
          ; number_of_positions = 93
          ; k_pos_per_s = 14_220
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_strong; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_ms 5.594
          ; number_of_positions = 207_900
          ; k_pos_per_s = 37_170
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_strong; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time_ns.Span.of_ms 52.45
          ; number_of_positions = 1_731_000
          ; k_pos_per_s = 33_000
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_strong; test_basename = "Test_L1_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_sec 4.727
          ; number_of_positions = 156_400_000
          ; k_pos_per_s = 33_090
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_strong; test_basename = "Test_L1_R2" }
    , { Result.mean =
          { span = Time_ns.Span.of_sec 8.2
          ; number_of_positions = 306_100_000
          ; k_pos_per_s = 37_330
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_weak; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_us 5.155
          ; number_of_positions = 67
          ; k_pos_per_s = 13_320
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_weak; test_basename = "Test_L2_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_ms 1.072
          ; number_of_positions = 28_750
          ; k_pos_per_s = 26_830
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_weak; test_basename = "Test_L2_R2" }
    , { Result.mean =
          { span = Time_ns.Span.of_ms 23.79
          ; number_of_positions = 752_300
          ; k_pos_per_s = 31_620
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_weak; test_basename = "Test_L1_R1" }
    , { Result.mean =
          { span = Time_ns.Span.of_sec 1.610
          ; number_of_positions = 52_840_000
          ; k_pos_per_s = 32_830
          }
      ; accuracy = 100.
      } )
  ; ( { Key.solver = trans_weak; test_basename = "Test_L1_R2" }
    , { Result.mean =
          { span = Time_ns.Span.of_sec 1.762
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

let add t ~bench:{ Bench.key; result } =
  let t = load_or_init ~filename:t.filename in
  t.entries <- Map.set t.entries ~key ~data:result;
  save t
;;

let to_ascii_table t =
  Bench.to_ascii_table
    ~entries:t.entries
    (Map.to_alist t.entries |> List.map ~f:(fun (key, result) -> { Bench.key; result }))
;;
