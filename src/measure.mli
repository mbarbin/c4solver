open! Core

type t =
  { span : Time.Span.t
  ; number_of_positions : int
  }
[@@deriving sexp_of]

module Mean : sig
  type t =
    { span : Time.Span.t
    ; number_of_positions : int
    ; k_pos_per_s : int
    }
  [@@deriving sexp]
end

val mean : t list -> Mean.t
