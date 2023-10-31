(** Currently this implementation does not optimize memory use and stores the
    keys and data as integers. We plan on optimizing this later while
    monitoring the impact on the benches. *)

type t

val create : size:int -> t
val put : t -> key:int -> data:int -> unit

(** Returns the value associated with the key if present, 0 otherwise. *)
val get : t -> key:int -> int

val reset : t -> unit
