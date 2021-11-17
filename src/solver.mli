open! Core

type t =
  { measure : Measure.t
  ; result : int
  }

val negamax : (module Position.S with type t = 'a) -> 'a -> t
