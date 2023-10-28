open! Base

type t =
  { span : Span.t
  ; number_of_positions : int
  }
[@@deriving sexp_of]

module Mean = struct
  type t =
    { span : Span.t
    ; number_of_positions : int
    ; k_pos_per_s : int
    }
  [@@deriving compare, equal, sexp]

  let zero = { span = Span.zero; number_of_positions = 0; k_pos_per_s = 0 }
end

let mean ts =
  if List.is_empty ts
  then Mean.zero
  else (
    let span = ref Span.zero in
    let number_of_positions = ref 0 in
    let count = ref 0 in
    List.iter ts ~f:(fun t ->
      span := Span.add !span t.span;
      number_of_positions := !number_of_positions + t.number_of_positions;
      count := !count + 1);
    let span = Span.divide !span ~by:!count in
    let number_of_positions =
      Float.iround_exn ~dir:`Nearest Int.(!number_of_positions // !count)
    in
    { Mean.span
    ; number_of_positions
    ; k_pos_per_s =
        (let ms = Span.to_ms span in
         if Float.equal ms 0.
         then 0
         else Float.iround_exn (Float.of_int number_of_positions /. ms))
    })
;;
