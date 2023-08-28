open! Core

module Test_line : sig
  type t =
    { position : string
    ; result : int
    }

  val parse_exn : string -> t

  val make_position
    :  t
    -> height:int
    -> width:int
    -> (module Position.S with type t = 'p)
    -> 'p
end

module Test_file : sig
  type t =
    { basename : string
    ; test_lines : Test_line.t Array.t
    }

  val load_exn : filename:string -> t
end

module Solver : sig
  module Lang : sig
    type t =
      | Cpp
      | Ocaml
      | Rust
    [@@deriving enumerate, compare, equal, sexp]
  end

  module Params : sig
    type t =
      { position : Position.t
      ; alpha_beta : bool
      ; weak : bool
      ; column_exploration_reorder : bool
      ; with_transposition_table : bool
      ; iterative_deepening : bool
      ; reference : bool
      ; lang : Lang.t
      }
  end

  (** A solver is obtained by selecting various parameters. It has a short human
      readable name for display purposes. *)
  type t =
    { step : Step.t
    ; weak : bool
    ; reference : bool
    ; lang : Lang.t
    }
  [@@deriving enumerate, compare, equal, sexp]

  val to_string_hum : t -> string
  val of_params : Params.t -> t
  val to_params : t -> Params.t
end

module Key : sig
  type t =
    { solver : Solver.t
    ; test_basename : string
    }
  [@@deriving compare, sexp]

  include Comparator.S with type t := t
end

module Result : sig
  type t =
    { mean : Measure.Mean.t
    ; accuracy : float
    }
  [@@deriving compare, sexp]
end

type t =
  { key : Key.t
  ; result : Result.t
  }
[@@deriving compare, sexp]

val to_ascii_table
  :  ?entries:Result.t Map.M(Key).t
  -> ?accuracy_only:bool
  -> t list
  -> string
