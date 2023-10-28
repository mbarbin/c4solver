open! Base

(** Adding human readable serializers based on [Core.Time_ns.Span]. *)

type t = Mtime.Span.t [@@deriving compare, equal, sexp]

val to_string_hum : t -> string

(** Divide by a given integer to compute a mean span from a total of spans
    accumulated over several executions. *)
val divide : t -> by:int -> t

val to_ms : t -> float
val zero : t
val add : t -> t -> t

(** Build from a number of small units *)

val of_us : float -> t
val of_ms : float -> t
val of_sec : float -> t
