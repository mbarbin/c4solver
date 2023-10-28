open! Base

type t =
  | MinMax
  | Alpha_beta
  | Column_exploration_order
  | Bitboard
  | Transposition_table
  | Iterative_deepening
[@@deriving compare, equal, enumerate, sexp]

let to_string_hum = function
  | MinMax -> "MinMax"
  | Alpha_beta -> "Alpha-beta"
  | Column_exploration_order -> "Column exploration order"
  | Bitboard -> "Bitboard"
  | Transposition_table -> "Transposition table"
  | Iterative_deepening -> "Iterative deepening"
;;
