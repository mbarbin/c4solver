open! Core

type t =
  { measure : Measure.t
  ; result : int
  }

val negamax : (module Position.S with type t = 'a) -> 'a -> t

val negamax_alpha_beta
  :  (module Position.S with type t = 'a)
  -> 'a
  -> weak:bool
  -> column_exploration_reorder:bool
  -> with_transposition_table:bool
  -> iterative_deepening:bool
  -> t
