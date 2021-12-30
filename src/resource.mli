open! Core

type t =
  | Test_L3_R1
  | Test_L2_R1
  | Test_L2_R2
  | Test_L1_R1
  | Test_L1_R2
  | Test_L1_R3
[@@deriving equal, compare, enumerate, sexp]

(** Assuming the resources are indexed with the range [1, 6], create
   the list of resources up to the given index. *)
val up_to : int -> t list
