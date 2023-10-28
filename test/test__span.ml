open! Base
open! C4solver
open! Expect_test_helpers_base

(* In practice (Span.of_sec 8.2) was not serialized as the sexp [8.2s], but
   rather [8.199999999s]. Monitoring to avoid a regression. *)

let%expect_test "span.sexp" =
  let print t =
    print_s [%sexp { to_string_hum = (Span.to_string_hum t : string); t : Span.t }]
  in
  print (Sexp.Atom "8.2s" |> [%of_sexp: Span.t]);
  [%expect {|
    ((to_string_hum 8.2s)
     (t             8.2s)) |}];
  print (Span.of_sec 8.2);
  [%expect {|
    ((to_string_hum 8.2s)
     (t             8.2s)) |}];
  ()
;;
