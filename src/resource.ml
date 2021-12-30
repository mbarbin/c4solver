open! Core

type t =
  | Test_L3_R1
  | Test_L2_R1
  | Test_L2_R2
  | Test_L1_R1
  | Test_L1_R2
  | Test_L1_R3
[@@deriving equal, compare, enumerate, sexp]

let up_to i = List.take all i
