open! Stdio

let resources_up_to ~(step : Step.t) =
  match step with
  | MinMax -> 1
  | Alpha_beta -> 1
  | Column_exploration_order -> 2
  | Bitboard -> 3
  | Transposition_table -> 3
  | Iterative_deepening -> 4
;;

let resources ~step = Resource.up_to (resources_up_to ~step)

let weak ~(step : Step.t) =
  match step with
  | MinMax -> false
  | Alpha_beta
  | Column_exploration_order
  | Bitboard
  | Transposition_table
  | Iterative_deepening -> true
;;

let rust_step_name ~(step : Step.t) =
  match step with
  | MinMax -> "MinMax"
  | Alpha_beta -> "AlphaBeta"
  | Column_exploration_order -> "ColumnExplorationOrder"
  | Bitboard -> "Bitboard"
  | Transposition_table -> "TranspositionTable"
  | Iterative_deepening -> "IterativeDeepening"
;;

let aux_gen_ocaml ~(step : Step.t) ~(resource : Resource.t) ~weak =
  Printf.sprintf
    "dune exec c4solver -- bench run resources/%s --step %s%s\n"
    (Sexp.to_string [%sexp (resource : Resource.t)])
    (Sexp.to_string [%sexp (step : Step.t)])
    (if weak then " --weak" else "")
;;

let aux_gen_rust ~(step : Step.t) ~(resource : Resource.t) ~weak ~padding =
  let weak_param = " --weak" in
  let weak_padding = String.make (String.length weak_param) ' ' in
  Printf.sprintf
    "dune exec c4solver -- bench external-solver --step %s --lang rust resources/%s%s -- \
     $PWD/target/release/c4solver --step %s%s\n"
    (Sexp.to_string [%sexp (step : Step.t)])
    (Sexp.to_string [%sexp (resource : Resource.t)])
    (if weak then weak_param else if padding then weak_padding else "")
    (rust_step_name ~step)
    (if weak then weak_param else "")
;;

let gen_ocaml ~(step : Step.t) =
  let resources = resources ~step in
  let weak = if weak ~step then [ false; true ] else [ false ] in
  (let open List.Let_syntax in
   let%map weak = weak
   and resource = resources in
   aux_gen_ocaml ~step ~resource ~weak)
  |> String.concat ~sep:""
;;

let gen_rust ~(step : Step.t) =
  let resources = resources ~step in
  let has_weak = weak ~step in
  let weak = if has_weak then [ false; true ] else [ false ] in
  (let open List.Let_syntax in
   let%map weak = weak
   and resource = resources in
   aux_gen_rust ~step ~resource ~weak ~padding:has_weak)
  |> String.concat ~sep:""
;;

let script_name ~(step : Step.t) ~(lang : Bench.Solver.Lang.t) =
  let suffix =
    match lang with
    | Cpp -> "-cpp"
    | Ocaml -> ""
    | Rust -> "-rs"
  in
  let step_name =
    Sexp.to_string [%sexp (step : Step.t)]
    |> String.lowercase
    |> String.map ~f:(function
      | '_' -> '-'
      | c -> c)
  in
  Printf.sprintf "run-%s%s.sh" step_name suffix
;;

let gen ~script_dir =
  let ( ^/ ) = Filename_base.concat in
  List.iter Step.all ~f:(fun step ->
    let ocaml = gen_ocaml ~step in
    let rust = gen_rust ~step in
    let ocaml_script = script_name ~step ~lang:Ocaml in
    let rust_script = script_name ~step ~lang:Rust in
    Stdio.Out_channel.write_all (script_dir ^/ ocaml_script) ~data:ocaml;
    Stdio.Out_channel.write_all (script_dir ^/ rust_script) ~data:rust)
;;

let main =
  Command.basic
    ~summary:"generate run scripts"
    (let%map_open.Command script_dir =
       flag "--script-dir" (required string) ~doc:"path abs path to script dir"
     in
     fun () -> gen ~script_dir)
;;
