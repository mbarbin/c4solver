module type S = sig
  (** Represent a connect4 game position. Columns are 0-based. *)
  type t [@@deriving sexp_of]

  val width : t -> int
  val height : t -> int
  val key : [ `not_available | `some of t -> int ]

  (** Create a new position from the given sizes. *)
  val create : width:int -> height:int -> t

  (** Return a deep copy of [t], for use in searching algorithm. The two
      positions can diverge freely from there without affecting each other. *)
  val copy : t -> t

  (** The given column can be played if it is not currently completely filled. *)
  val can_play : t -> column:int -> bool

  (** Given a free column, place a token of the next player to play there. *)
  val play : t -> column:int -> unit

  (** Indicates whether the current player wins by playing in this column. *)
  val is_winning_move : t -> column:int -> bool

  (** Return the number of plies that have been played from the beginning. This
      is the number of times [play] has been called. *)
  val number_of_plies : t -> int

  val to_ascii_table : t -> string
end

module type Position = sig
  module type S = S

  (** A basic implementation for [S], with the board represented by a token
      matrix. *)
  module Basic : S

  (** A more effecient implementation based on a clever use of bit operations. *)
  module Bitboard : S

  (** [t] Allows for dynamically choosing the implementation among those
      available. *)
  type t =
    | Basic
    | Bitboard
  [@@deriving compare, equal, enumerate, sexp_of]

  val get : t -> (module S)

  (** Additional implementations - used for tests only. *)

  module Bitboard_uint : S
  module Bitboard64 : S
  module Bitboard128 : S
end
