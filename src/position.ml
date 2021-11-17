open! Base
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
    let board = Array.make_matrix width height Cell.Empty in
    let height = Array.create width 0 in
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
