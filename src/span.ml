open! Base

type t = Mtime.Span.t

let equal = Mtime.Span.equal
let compare = Mtime.Span.compare

let to_time_ns_span t =
  t |> Mtime.Span.to_uint64_ns |> Int63.of_int64_exn |> Core.Time_ns.Span.of_int63_ns
;;

let of_time_ns_span s =
  s |> Core.Time_ns.Span.to_int63_ns |> Int63.to_int64 |> Mtime.Span.of_uint64_ns
;;

include
  Sexpable.Of_sexpable
    (Core.Time_ns.Span)
    (struct
      type nonrec t = t

      let to_sexpable = to_time_ns_span
      let of_sexpable = of_time_ns_span
    end)

let to_string_hum t = t |> to_time_ns_span |> Core.Time_ns.Span.to_string_hum

let divide t ~by =
  let ns = t |> Mtime.Span.to_uint64_ns in
  Int64.( / ) ns (Int64.of_int by) |> Mtime.Span.of_uint64_ns
;;

let scale_exn t f =
  let f = Bignum.of_float_decimal f in
  let t = Bignum.of_bigint (Bigint.of_int64 (Mtime.Span.to_uint64_ns t)) in
  Bignum.( * ) t f
  |> Bignum.round_as_bigint_exn
  |> Bigint.to_int64_exn
  |> Mtime.Span.of_uint64_ns
;;

let zero = Mtime.Span.zero
let add = Mtime.Span.add
let of_us f = scale_exn Mtime.Span.us f
let of_ms f = scale_exn Mtime.Span.ms f
let of_sec f = scale_exn Mtime.Span.s f
let to_ms t = Mtime.Span.to_float_ns t /. 1_000_000.
