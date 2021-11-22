open! Core

(** A bench db is a local file where we store bench results as we
   gather them using the [bench run] command. The motivation for
   storing them is so that we can show them all together in nice
   tables, and avoid re-running benches that we have already run too
   many times unintentionally. *)

type t

(** Load an existing [t] at given filename, or initialize an empty db
   if not present. *)
val load_or_init : filename:string -> t

(** Say if there exists an entry with given solver. *)
val mem : t -> key:Bench.Key.t -> bool

(** Reload the db, add an entry overwriting any previous one if any
   already exists with [bench.key], and save to disk. *)
val add : t -> bench:Bench.t -> unit

val to_ascii_table : t -> string
