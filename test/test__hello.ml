open! Core

let%expect_test "hello" =
  print_s My_package.hello_world;
  [%expect {| "Hello, World!" |}]
;;
