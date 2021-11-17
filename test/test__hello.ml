open! Core

let%expect_test "hello" =
  print_s C4solver.hello_world;
  [%expect {| "Hello, World!" |}]
;;
