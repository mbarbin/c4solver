open! Core

module Result_with_measure : sig
  type t =
    { measure : Measure.t
    ; result : int
    }
end

val negamax : (module Position.S with type t = 'a) -> 'a -> Result_with_measure.t

val negamax_alpha_beta
  :  (module Position.S with type t = 'a)
  -> 'a
  -> weak:bool
  -> column_exploration_reorder:bool
  -> with_transposition_table:bool
  -> iterative_deepening:bool
  -> Result_with_measure.t
