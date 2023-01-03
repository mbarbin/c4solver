open! Core
open! C4solver
open! Expect_test_helpers_core

(* In this test, we check the consistency of the results computed by
   the various implementations available in the [Position] module.

   For each test case, we run all positions implementation, and fail
   if differences in results are detected. *)

let implementations : (module Position.S) list =
  [ (module Position.Basic)
  ; (module Position.Bitboard)
  ; (module Position.Bitboard_uint)
  ; (module Position.Bitboard64)
  ; (module Position.Bitboard128)
  ]
;;

let height = 6
let width = 7

type t =
  { number_of_plies : int
  ; can_play : (int * bool) list
  ; is_winning : (int * bool) list
  ; ascii_table : string [@sexp.sexp_drop_if Fn.const true]
  }
[@@deriving equal, sexp_of]

let eval ~test_line (module P : Position.S) =
  let position = Bench.Test_line.make_position test_line ~height ~width (module P) in
  let number_of_plies = P.number_of_plies position in
  assert (number_of_plies = String.length test_line.position);
  let can_play = List.init width ~f:(fun column -> column, P.can_play position ~column) in
  let is_winning =
    List.filter_map can_play ~f:(fun (column, can_play) ->
      if not can_play then None else Some (column, P.is_winning_move position ~column))
  in
  { number_of_plies; can_play; is_winning; ascii_table = P.to_ascii_table position }
;;

let test_line line =
  let test_line = Bench.Test_line.parse_exn line in
  let results = List.map implementations ~f:(eval ~test_line) in
  let t =
    match results with
    | [] -> assert false
    | e1 :: tl ->
      List.iter tl ~f:(fun e2 ->
        if not (equal e1 e2)
        then (
          print_string e1.ascii_table;
          print_string e2.ascii_table;
          raise_s [%sexp "Inconsistent evaluation", [%here], { e1 : t; e2 : t }]));
      e1
  in
  print_string t.ascii_table;
  print_s [%sexp ({ t with ascii_table = "" } : t)]
;;

let%expect_test "Test_L3_R1 #1" =
  require_does_not_raise [%here] (fun () ->
    test_line "2252576253462244111563365343671351441 -1");
  [%expect
    {|
    ┌───┬───┬───┬───┬───┬───┬───┐
    │ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │
    ├───┼───┼───┼───┼───┼───┼───┤
    │ X │ 0 │ 0 │ 0 │ X │   │   │
    │ 0 │ X │ 0 │ X │ X │ X │   │
    │ X │ 0 │ 0 │ X │ 0 │ 0 │   │
    │ X │ 0 │ X │ 0 │ X │ X │   │
    │ 0 │ 0 │ 0 │ X │ X │ 0 │ 0 │
    │ X │ X │ 0 │ X │ X │ X │ 0 │
    └───┴───┴───┴───┴───┴───┴───┘
    ((number_of_plies 37)
     (can_play (
       (0 false)
       (1 false)
       (2 false)
       (3 false)
       (4 false)
       (5 true)
       (6 true)))
     (is_winning (
       (5 false)
       (6 false)))) |}]
;;

let%expect_test "Test_L3_R1 #3" =
  require_does_not_raise [%here] (fun () ->
    test_line "23163416124767223154467471272416755633 0");
  [%expect
    {|
    ┌───┬───┬───┬───┬───┬───┬───┐
    │ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │
    ├───┼───┼───┼───┼───┼───┼───┤
    │ X │ X │   │ 0 │   │ 0 │ X │
    │ 0 │ X │ 0 │ 0 │   │ 0 │ 0 │
    │ 0 │ 0 │ X │ X │   │ 0 │ X │
    │ X │ X │ X │ 0 │ X │ X │ X │
    │ X │ 0 │ X │ X │ 0 │ 0 │ 0 │
    │ X │ X │ 0 │ 0 │ X │ 0 │ 0 │
    └───┴───┴───┴───┴───┴───┴───┘
    ((number_of_plies 38)
     (can_play (
       (0 false)
       (1 false)
       (2 true)
       (3 false)
       (4 true)
       (5 false)
       (6 false)))
     (is_winning (
       (2 false)
       (4 false)))) |}]
;;

let%expect_test "Test_L2_R1 #1" =
  require_does_not_raise [%here] (fun () -> test_line "5554224333234511764415115 4");
  [%expect
    {|
    ┌───┬───┬───┬───┬───┬───┬───┐
    │ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │
    ├───┼───┼───┼───┼───┼───┼───┤
    │   │   │   │   │ X │   │   │
    │ 0 │   │   │ 0 │ 0 │   │   │
    │ X │   │ 0 │ X │ 0 │   │   │
    │ X │ X │ 0 │ X │ X │   │   │
    │ 0 │ 0 │ X │ X │ 0 │   │   │
    │ X │ X │ 0 │ 0 │ X │ 0 │ X │
    └───┴───┴───┴───┴───┴───┴───┘
    ((number_of_plies 25)
     (can_play (
       (0 true)
       (1 true)
       (2 true)
       (3 true)
       (4 false)
       (5 true)
       (6 true)))
     (is_winning (
       (0 false)
       (1 false)
       (2 false)
       (3 false)
       (5 false)
       (6 false)))) |}]
;;

let%expect_test "Test_L2_R1 #29" =
  require_does_not_raise [%here] (fun () -> test_line "2737772244262123677516643354 0");
  [%expect
    {|
    ┌───┬───┬───┬───┬───┬───┬───┐
    │ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │
    ├───┼───┼───┼───┼───┼───┼───┤
    │   │ X │   │   │   │   │ X │
    │   │ X │   │   │   │   │ 0 │
    │   │ X │ 0 │ 0 │   │ X │ 0 │
    │   │ 0 │ X │ 0 │   │ 0 │ X │
    │ X │ X │ 0 │ 0 │ X │ X │ 0 │
    │ 0 │ X │ X │ X │ 0 │ 0 │ 0 │
    └───┴───┴───┴───┴───┴───┴───┘
    ((number_of_plies 28)
     (can_play (
       (0 true)
       (1 false)
       (2 true)
       (3 true)
       (4 true)
       (5 true)
       (6 false)))
     (is_winning (
       (0 false)
       (2 false)
       (3 false)
       (4 false)
       (5 false)))) |}]
;;

let%expect_test "Test_L2_R2 #1" =
  require_does_not_raise [%here] (fun () -> test_line "274552224131661 0");
  [%expect
    {|
    ┌───┬───┬───┬───┬───┬───┬───┐
    │ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │
    ├───┼───┼───┼───┼───┼───┼───┤
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │   │ 0 │   │   │   │   │   │
    │ X │ X │   │   │   │   │   │
    │ 0 │ 0 │   │ X │ X │ 0 │   │
    │ 0 │ X │ X │ X │ 0 │ X │ 0 │
    └───┴───┴───┴───┴───┴───┴───┘
    ((number_of_plies 15)
     (can_play (
       (0 true)
       (1 true)
       (2 true)
       (3 true)
       (4 true)
       (5 true)
       (6 true)))
     (is_winning (
       (0 false)
       (1 false)
       (2 false)
       (3 false)
       (4 false)
       (5 false)
       (6 false)))) |}]
;;

let%expect_test "Test_L2_R2 #17" =
  require_does_not_raise [%here] (fun () -> test_line "555317266147361 -1");
  [%expect
    {|
    ┌───┬───┬───┬───┬───┬───┬───┐
    │ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │
    ├───┼───┼───┼───┼───┼───┼───┤
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │ X │   │   │   │ X │ 0 │   │
    │ 0 │   │ X │   │ 0 │ X │ 0 │
    │ X │ X │ 0 │ X │ X │ 0 │ 0 │
    └───┴───┴───┴───┴───┴───┴───┘
    ((number_of_plies 15)
     (can_play (
       (0 true)
       (1 true)
       (2 true)
       (3 true)
       (4 true)
       (5 true)
       (6 true)))
     (is_winning (
       (0 false)
       (1 false)
       (2 false)
       (3 false)
       (4 false)
       (5 false)
       (6 false)))) |}]
;;

let%expect_test "Test_L1_R1 #1" =
  require_does_not_raise [%here] (fun () -> test_line "32164625 11");
  [%expect
    {|
    ┌───┬───┬───┬───┬───┬───┬───┐
    │ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │
    ├───┼───┼───┼───┼───┼───┼───┤
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │   │ X │   │   │   │ 0 │   │
    │ X │ 0 │ X │ X │ 0 │ 0 │   │
    └───┴───┴───┴───┴───┴───┴───┘
    ((number_of_plies 8)
     (can_play (
       (0 true)
       (1 true)
       (2 true)
       (3 true)
       (4 true)
       (5 true)
       (6 true)))
     (is_winning (
       (0 false)
       (1 false)
       (2 false)
       (3 false)
       (4 false)
       (5 false)
       (6 false)))) |}]
;;

let%expect_test "Test_L1_R1 #67" =
  require_does_not_raise [%here] (fun () -> test_line "25144 18");
  [%expect
    {|
    ┌───┬───┬───┬───┬───┬───┬───┐
    │ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │
    ├───┼───┼───┼───┼───┼───┼───┤
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │   │   │   │ X │   │   │   │
    │ X │ X │   │ 0 │ 0 │   │   │
    └───┴───┴───┴───┴───┴───┴───┘
    ((number_of_plies 5)
     (can_play (
       (0 true)
       (1 true)
       (2 true)
       (3 true)
       (4 true)
       (5 true)
       (6 true)))
     (is_winning (
       (0 false)
       (1 false)
       (2 false)
       (3 false)
       (4 false)
       (5 false)
       (6 false)))) |}]
;;

let%expect_test "Test_L1_R2 #1" =
  require_does_not_raise [%here] (fun () -> test_line "32751571231557 -3");
  [%expect
    {|
    ┌───┬───┬───┬───┬───┬───┬───┐
    │ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │
    ├───┼───┼───┼───┼───┼───┼───┤
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │   │   │   │   │ X │   │   │
    │ X │   │   │   │ 0 │   │ 0 │
    │ 0 │ X │ 0 │   │ 0 │   │ X │
    │ X │ 0 │ X │   │ 0 │   │ X │
    └───┴───┴───┴───┴───┴───┴───┘
    ((number_of_plies 14)
     (can_play (
       (0 true)
       (1 true)
       (2 true)
       (3 true)
       (4 true)
       (5 true)
       (6 true)))
     (is_winning (
       (0 false)
       (1 false)
       (2 false)
       (3 false)
       (4 false)
       (5 false)
       (6 false)))) |}]
;;

let%expect_test "Test_L1_R2 #31" =
  require_does_not_raise [%here] (fun () -> test_line "75734233473735 0");
  [%expect
    {|
    ┌───┬───┬───┬───┬───┬───┬───┐
    │ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │
    ├───┼───┼───┼───┼───┼───┼───┤
    │   │   │   │   │   │   │   │
    │   │   │ X │   │   │   │   │
    │   │   │ X │   │   │   │ 0 │
    │   │   │ 0 │   │   │   │ 0 │
    │   │   │ X │ X │ 0 │   │ X │
    │   │ 0 │ 0 │ X │ 0 │   │ X │
    └───┴───┴───┴───┴───┴───┴───┘
    ((number_of_plies 14)
     (can_play (
       (0 true)
       (1 true)
       (2 true)
       (3 true)
       (4 true)
       (5 true)
       (6 true)))
     (is_winning (
       (0 false)
       (1 false)
       (2 false)
       (3 false)
       (4 false)
       (5 false)
       (6 false)))) |}]
;;

let%expect_test "Test_L1_R3 #1" =
  require_does_not_raise [%here] (fun () -> test_line "13712 3");
  [%expect
    {|
    ┌───┬───┬───┬───┬───┬───┬───┐
    │ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │
    ├───┼───┼───┼───┼───┼───┼───┤
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │ 0 │   │   │   │   │   │   │
    │ X │ X │ 0 │   │   │   │ X │
    └───┴───┴───┴───┴───┴───┴───┘
    ((number_of_plies 5)
     (can_play (
       (0 true)
       (1 true)
       (2 true)
       (3 true)
       (4 true)
       (5 true)
       (6 true)))
     (is_winning (
       (0 false)
       (1 false)
       (2 false)
       (3 false)
       (4 false)
       (5 false)
       (6 false)))) |}]
;;

let%expect_test "Test_L1_R3 #15" =
  require_does_not_raise [%here] (fun () -> test_line "527376 0");
  [%expect
    {|
    ┌───┬───┬───┬───┬───┬───┬───┐
    │ 0 │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │
    ├───┼───┼───┼───┼───┼───┼───┤
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │   │
    │   │   │   │   │   │   │ X │
    │   │ 0 │ 0 │   │ X │ 0 │ X │
    └───┴───┴───┴───┴───┴───┴───┘
    ((number_of_plies 6)
     (can_play (
       (0 true)
       (1 true)
       (2 true)
       (3 true)
       (4 true)
       (5 true)
       (6 true)))
     (is_winning (
       (0 false)
       (1 false)
       (2 false)
       (3 false)
       (4 false)
       (5 false)
       (6 false)))) |}]
;;
