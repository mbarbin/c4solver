open! Core

(** A bench db is a local file where we store bench results as we
   gather them using the [bench run] command. The motivation for
   storing them is so that we can show them all together in nice
   tables, and avoid re-running benches that we have already run too
   many times unintentionally. *)

module Solver : sig
  module Params : sig
    type t =
      { position : Position.t
      ; alpha_beta : bool
      ; weak : bool
      ; column_exploration_reorder : bool
      ; with_transposition_table : bool
      ; reference : bool
      }
  end

  (** A solver is obtained by selecting various parameters. It has a
     short human readable name for display purposes. *)
  type t [@@deriving enumerate, sexp_of]

  val to_string_hum : t -> string
  val of_params : Params.t -> t
  val to_params : t -> Params.t
end

module Key : sig
  type t =
    { test_basename : string
    ; solver : Solver.t
    }
end

module Result : sig
  type t =
    { mean : Measure.Mean.t
    ; accuracy : float
    }
end

type t

(** Load an existing [t] at given filename, or initialize an empty db
   if not present. *)
val load_or_init : filename:string -> t

(** Say if there exists an entry with given solver. *)
val mem : t -> key:Key.t -> bool

(** Reload the db, add an entry overwriting any previous one, and save
   to disk. *)
val add : t -> key:Key.t -> result:Result.t -> unit

val to_ascii_table : t -> string
