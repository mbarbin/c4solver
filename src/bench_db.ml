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
    type t = MinMax [@@deriving compare, equal, enumerate, sexp]
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
      (Sexp.to_string (Human_name.sexp_of_t t.human_name))
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
  module T = struct
    type t =
      { solver : Solver.t
      ; test_basename : string
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
  [ ( { Key.solver = minmax; test_basename = "Test_L3_R1" }
    , { Result.mean =
          { span = Time.Span.of_us 790.28
          ; number_of_positions = 11_024
          ; k_pos_per_s = 13_950
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
  let headers =
    [ "solver"; "test"; "accuracy"; "mean time"; "mean nb of pos"; "K pos / s" ]
  in
  let data =
    Map.to_alist t.entries
    |> List.map ~f:(fun (key, result) ->
           [ Solver.to_string_hum key.solver
           ; key.test_basename
           ; sprintf "%.2f%%" result.accuracy
           ; Time.Span.to_string_hum result.mean.span
           ; Int.to_string_hum result.mean.number_of_positions
           ; Int.to_string_hum result.mean.k_pos_per_s
           ])
  in
  Ascii_table.simple_list_table_string headers data
;;
