open! Core

type t =
  | MinMax
  | Alpha_beta
  | Column_exploration_order
  | Bitboard
  | Transposition_table
  | Iterative_deepening
[@@deriving compare, equal, enumerate, sexp]

val to_string_hum : t -> string
