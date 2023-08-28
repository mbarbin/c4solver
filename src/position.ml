open! Core
include Position_intf

module Basic : S = struct
  module Player = struct
    type t =
      | Red
      | Yellow
    [@@deriving compare, equal, sexp_of]
  end

  module Cell = struct
    type t =
      | Empty
      | Token of { player : Player.t }
    [@@deriving compare, equal, sexp_of]
  end

  type t =
    { board : Cell.t Array.t Array.t
    ; height : int Array.t
    ; mutable number_of_plies : int
    }
  [@@deriving sexp_of]

  let width t = Array.length t.board
  let height t = if width t = 0 then 0 else Array.length t.board.(0)
  let key = `not_available

  let to_ascii_table t =
    let headers = List.init (width t) ~f:(fun i -> Int.to_string i) in
    let data =
      List.init (height t) ~f:(fun line ->
        let line = height t - 1 - line in
        List.init (width t) ~f:(fun column ->
          match t.board.(column).(line) with
          | Empty -> " "
          | Token { player = Red } -> "X"
          | Token { player = Yellow } -> "0"))
    in
    Ascii_table.simple_list_table_string headers data
  ;;

  let copy t =
    { board = Array.copy_matrix t.board
    ; height = Array.copy t.height
    ; number_of_plies = t.number_of_plies
    }
  ;;

  let next_player_to_play t =
    if t.number_of_plies % 2 = 0 then Player.Red else Player.Yellow
  ;;

  let create ~width ~height =
    let board = Array.make_matrix ~dimx:width ~dimy:height Cell.Empty in
    let height = Array.create ~len:width 0 in
    { board; height; number_of_plies = 0 }
  ;;

  let can_play t ~column = t.height.(column) < height t
  let number_of_plies t = t.number_of_plies

  let play t ~column =
    let player = next_player_to_play t in
    let line = t.height.(column) in
    t.board.(column).(line) <- Token { player };
    t.height.(column) <- Int.succ line;
    t.number_of_plies <- Int.succ t.number_of_plies
  ;;

  module Is_winning = struct
    let vertical = 0, -1
    let left_horizontal = -1, 0
    let right_horizontal = 1, 0
    let left_south_west_north_east_diagonal = -1, -1
    let right_south_west_north_east_diagonal = 1, 1
    let left_north_west_south_east_diagonal = -1, 1
    let right_north_west_south_east_diagonal = 1, -1

    let trials =
      [ vertical, (0, 1)
      ; left_horizontal, right_horizontal
      ; left_south_west_north_east_diagonal, right_south_west_north_east_diagonal
      ; left_north_west_south_east_diagonal, right_north_west_south_east_diagonal
      ]
    ;;
  end

  let is_winning_move t ~column =
    let width = width t in
    let height = height t in
    let player = next_player_to_play t in
    let cell = Cell.Token { player } in
    let line = t.height.(column) in
    let rec count acc (x, y) (dx, dy) =
      if acc >= 3
      then acc
      else (
        let x = x + dx
        and y = y + dy in
        if x < 0
           || y < 0
           || x >= width
           || y >= height
           || not (Cell.equal cell t.board.(x).(y))
        then acc
        else count (acc + 1) (x, y) (dx, dy))
    in
    List.exists Is_winning.trials ~f:(fun (left, right) ->
      let acc = count 0 (column, line) left in
      let acc = count acc (column, line) right in
      acc >= 3)
  ;;
end

module type Uint = sig
  type t

  val to_string : t -> string
  val to_int : t -> int
  val one : t
  val zero : t
  val pred : t -> t
  val add : t -> t -> t
  val compare : t -> t -> int
  val logand : t -> t -> t
  val logor : t -> t -> t
  val logxor : t -> t -> t
  val shift_left : t -> int -> t
  val shift_right : t -> int -> t
end

module Make_bitboard (Uint : Uint) : S = struct
  (* From: http://blog.gamesolver.org/solving-connect-four/06-bitboard
   *
   * A binary bitboard representationis used.
   * Each column is encoded on HEIGH+1 bits.
   *
   * Example of bit order to encode for a 7x6 board
   * .  .  .  .  .  .  .
   * 5 12 19 26 33 40 47
   * 4 11 18 25 32 39 46
   * 3 10 17 24 31 38 45
   * 2  9 16 23 30 37 44
   * 1  8 15 22 29 36 43
   * 0  7 14 21 28 35 42
   *
   * Position is stored as
   * - a bitboard "mask" with 1 on any color stones
   * - a bitboard "current_player" with 1 on stones of current player
   *
   * "current_player" bitboard can be transformed into a compact and non ambiguous key
   * by adding an extra bit on top of the last non empty cell of each column.
   * This allow to identify all the empty cells whithout needing "mask" bitboard
   *
   * current_player "x" = 1, opponent "o" = 0
   * board     position  mask      key       bottom
   *           0000000   0000000   0000000   0000000
   * .......   0000000   0000000   0001000   0000000
   * ...o...   0000000   0001000   0010000   0000000
   * ..xx...   0011000   0011000   0011000   0000000
   * ..ox...   0001000   0011000   0001100   0000000
   * ..oox..   0000100   0011100   0000110   0000000
   * ..oxxo.   0001100   0011110   1101101   1111111
   *
   * current_player "o" = 1, opponent "x" = 0
   * board     position  mask      key       bottom
   *           0000000   0000000   0001000   0000000
   * ...x...   0000000   0001000   0000000   0000000
   * ...o...   0001000   0001000   0011000   0000000
   * ..xx...   0000000   0011000   0000000   0000000
   * ..ox...   0010000   0011000   0010100   0000000
   * ..oox..   0011000   0011100   0011010   0000000
   * ..oxxo.   0010010   0011110   1110011   1111111
   *
   * key is an unique representation of a board key = position + mask + bottom
   * in practice, as bottom is constant, key = position + mask is also a
   * non-ambigous representation of the position.
   *)

  type uint = Uint.t

  let sexp_of_uint t = Sexp.Atom (Uint.to_string t)

  type t =
    { width : int
    ; height : int
    ; mutable number_of_plies : int
    ; mutable position : uint
    ; mutable mask : uint
    }
  [@@deriving sexp_of]

  let copy { width; height; number_of_plies; position; mask } =
    { width; height; number_of_plies; position; mask }
  ;;

  let width t = t.width
  let height t = t.height
  let key = `some (fun t -> Uint.add t.position t.mask |> Uint.to_int)

  let create ~width ~height =
    { width; height; number_of_plies = 0; position = Uint.zero; mask = Uint.zero }
  ;;

  let is_zero u = 0 = Uint.compare Uint.zero u

  let top_mask_col t ~column =
    Uint.shift_left Uint.one (t.height - 1 + (column * (t.height + 1)))
  ;;

  let bottom_mask_col t ~column = Uint.shift_left Uint.one (column * (t.height + 1))
  let can_play t ~column = is_zero (Uint.logand t.mask (top_mask_col t ~column))

  let column_mask t ~column =
    Uint.shift_left
      (Uint.shift_left Uint.one t.height |> Uint.pred)
      (column * (t.height + 1))
  ;;

  let move_mask t ~column =
    Uint.logand (Uint.add t.mask (bottom_mask_col t ~column)) (column_mask t ~column)
  ;;

  let play t ~column =
    let move = move_mask t ~column in
    t.position <- Uint.logxor t.position t.mask;
    t.mask <- Uint.logor t.mask move;
    t.number_of_plies <- Int.succ t.number_of_plies
  ;;

  let alignment t position =
    (* Horizontal. *)
    (let m = Uint.logand position (Uint.shift_right position (t.height + 1)) in
     not (is_zero (Uint.logand m (Uint.shift_right m (2 * (t.height + 1))))))
    (* Diagonal 1. *)
    || (let m = Uint.logand position (Uint.shift_right position t.height) in
        not (is_zero (Uint.logand m (Uint.shift_right m (2 * t.height)))))
    (* Diagonal 2. *)
    || (let m = Uint.logand position (Uint.shift_right position (t.height + 2)) in
        not (is_zero (Uint.logand m (Uint.shift_right m (2 * (t.height + 2))))))
    ||
    (* Vertical. *)
    let m = Uint.logand position (Uint.shift_right position 1) in
    not (is_zero (Uint.logand m (Uint.shift_right m 2)))
  ;;

  let is_winning_move t ~column =
    let position = Uint.logxor t.position (move_mask t ~column) in
    alignment t position
  ;;

  let number_of_plies t = t.number_of_plies

  let cell_mask t ~column ~line =
    Uint.shift_left Uint.one ((column * (t.height + 1)) + line)
  ;;

  let to_ascii_table t =
    let player, opponent = if t.number_of_plies % 2 = 0 then "X", "0" else "0", "X" in
    let headers = List.init (width t) ~f:(fun i -> Int.to_string i) in
    let data =
      List.init (height t) ~f:(fun line ->
        let line = height t - 1 - line in
        List.init (width t) ~f:(fun column ->
          let cell = cell_mask t ~column ~line in
          if is_zero (Uint.logand cell t.mask)
          then " "
          else if is_zero (Uint.logand cell t.position)
          then opponent
          else player))
    in
    Ascii_table.simple_list_table_string headers data
  ;;
end

module Uint = struct
  type t = int

  let to_string = Int.to_string

  external to_int : t -> int = "%identity" [@@inline]

  let one = 1
  let zero = 0
  let pred = Int.pred
  let add = ( + )
  let compare = Int.compare
  let logand a b = a land b [@@inline]
  let logor a b = a lor b [@@inline]
  let logxor a b = a lxor b [@@inline]
  let shift_left t i = t lsl i [@@inline]
  let shift_right t i = t lsr i [@@inline]
end

(* Bitboards 64 and 128 are not actually used, we just show that we can build it
   if we wanted to work with bigger boards. *)
module Bitboard64 = Make_bitboard (Stdint.Uint64)
module Bitboard128 = Make_bitboard (Stdint.Uint128)

(* In theory this is the bitboard that we would want to use, however sadly the
   fact that we are using a functor degrades performances. Perhaps using flambda
   would be something to consider and bench if interested. In practice we use an
   inlined version of this code, see below. *)
module Bitboard_uint = Make_bitboard (Uint)

(* We copy here verbatim the code of the functor [Make_bitboard], since the name
   of the argument [Uint] is the same as the name of the module above, this
   results in an inlined version of the same implementation. *)
module Bitboard = struct
  type uint = Uint.t

  let sexp_of_uint t = Sexp.Atom (Uint.to_string t)

  type t =
    { width : int
    ; height : int
    ; mutable number_of_plies : int
    ; mutable position : uint
    ; mutable mask : uint
    }
  [@@deriving sexp_of]

  let copy { width; height; number_of_plies; position; mask } =
    { width; height; number_of_plies; position; mask }
  ;;

  let width t = t.width
  let height t = t.height
  let key = `some (fun t -> Uint.add t.position t.mask |> Uint.to_int)

  let create ~width ~height =
    { width; height; number_of_plies = 0; position = Uint.zero; mask = Uint.zero }
  ;;

  let is_zero u = u = 0 [@@inline]

  let top_mask_col t ~column =
    Uint.shift_left Uint.one (t.height - 1 + (column * (t.height + 1)))
  ;;

  let bottom_mask_col t ~column = Uint.shift_left Uint.one (column * (t.height + 1))
  let can_play t ~column = is_zero (Uint.logand t.mask (top_mask_col t ~column))

  let column_mask t ~column =
    Uint.shift_left
      (Uint.shift_left Uint.one t.height |> Uint.pred)
      (column * (t.height + 1))
  ;;

  let move_mask t ~column =
    Uint.logand (Uint.add t.mask (bottom_mask_col t ~column)) (column_mask t ~column)
  ;;

  let play t ~column =
    let move = move_mask t ~column in
    t.position <- Uint.logxor t.position t.mask;
    t.mask <- Uint.logor t.mask move;
    t.number_of_plies <- Int.succ t.number_of_plies
  ;;

  let alignment t position =
    (* Horizontal. *)
    (let m = Uint.logand position (Uint.shift_right position (t.height + 1)) in
     not (is_zero (Uint.logand m (Uint.shift_right m (2 * (t.height + 1))))))
    (* Diagonal 1. *)
    || (let m = Uint.logand position (Uint.shift_right position t.height) in
        not (is_zero (Uint.logand m (Uint.shift_right m (2 * t.height)))))
    (* Diagonal 2. *)
    || (let m = Uint.logand position (Uint.shift_right position (t.height + 2)) in
        not (is_zero (Uint.logand m (Uint.shift_right m (2 * (t.height + 2))))))
    ||
    (* Vertical. *)
    let m = Uint.logand position (Uint.shift_right position 1) in
    not (is_zero (Uint.logand m (Uint.shift_right m 2)))
  ;;

  let is_winning_move t ~column =
    let position = Uint.logxor t.position (move_mask t ~column) in
    alignment t position
  ;;

  let number_of_plies t = t.number_of_plies

  let cell_mask t ~column ~line =
    Uint.shift_left Uint.one ((column * (t.height + 1)) + line)
  ;;

  let to_ascii_table t =
    let player, opponent = if t.number_of_plies % 2 = 0 then "X", "0" else "0", "X" in
    let headers = List.init (width t) ~f:(fun i -> Int.to_string i) in
    let data =
      List.init (height t) ~f:(fun line ->
        let line = height t - 1 - line in
        List.init (width t) ~f:(fun column ->
          let cell = cell_mask t ~column ~line in
          if is_zero (Uint.logand cell t.mask)
          then " "
          else if is_zero (Uint.logand cell t.position)
          then opponent
          else player))
    in
    Ascii_table.simple_list_table_string headers data
  ;;
end

type t =
  | Basic
  | Bitboard
[@@deriving compare, equal, enumerate, sexp_of]

let get = function
  | Basic -> (module Basic : S)
  | Bitboard -> (module Bitboard : S)
;;
