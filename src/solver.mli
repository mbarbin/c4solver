open! Core

type t =
  { measure : Measure.t
  ; result : int
  }

val negamax : (module Position.S with type t = 'a) -> 'a -> t
val negamax_alphabeta : (module Position.S with type t = 'a) -> 'a -> weak:bool -> t
