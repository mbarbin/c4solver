open! Core
open! C4solver
open! Expect_test_helpers_core

let height = 6
let width = 7

let test_line line =
  let test_line = Bencher.Test_line.parse_exn line in
  let position =
    Bencher.Test_line.make_position test_line ~height ~width (module Position.Basic)
  in
  assert (Position.Basic.number_of_plies position = String.length test_line.position);
  print_string (Position.Basic.to_ascii_table position);
  let can_play =
    List.init width ~f:(fun column -> column, Position.Basic.can_play position ~column)
  in
  let is_winning =
    List.filter_map can_play ~f:(fun (column, can_play) ->
        if not can_play
        then None
        else Some (column, Position.Basic.is_winning_move position ~column))
  in
  print_s
    [%sexp
      { number_of_plies = (Position.Basic.number_of_plies position : int)
      ; can_play : (int * bool) list
      ; is_winning : (int * bool) list
      }]
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
  [%expect {|
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
  [%expect {|
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
  [%expect {|
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
  [%expect {|
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
  [%expect {|
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
  [%expect {|
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
  [%expect {|
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
  [%expect {|
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
  [%expect {|
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
  [%expect {|
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
