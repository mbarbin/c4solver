open! Core

type t =
  { span : Time_ns.Span.t
  ; number_of_positions : int
  }
[@@deriving sexp_of]

module Mean = struct
  type t =
    { span : Time_ns.Span.t
    ; number_of_positions : int
    ; k_pos_per_s : int
    }
  [@@deriving sexp]

  let zero = { span = Time_ns.Span.zero; number_of_positions = 0; k_pos_per_s = 0 }
end

let mean ts =
  if List.is_empty ts
  then Mean.zero
  else (
    let span = ref Time_ns.Span.zero in
    let number_of_positions = ref 0 in
    let count = ref 0 in
    List.iter ts ~f:(fun t ->
        span := Time_ns.Span.( + ) !span t.span;
        number_of_positions := !number_of_positions + t.number_of_positions;
        count := !count + 1);
    let span = Time_ns.Span.( / ) !span (float_of_int !count) in
    let number_of_positions =
      Float.iround_exn
        ~dir:`Nearest
        (float_of_int !number_of_positions /. float_of_int !count)
    in
    { Mean.span
    ; number_of_positions
    ; k_pos_per_s =
        (if Float.equal (Time_ns.Span.to_ms span) 0.
        then 0
        else int_of_float (float_of_int number_of_positions /. Time_ns.Span.to_ms span))
    })
;;
