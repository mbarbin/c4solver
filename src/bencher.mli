open! Core

module Test_line : sig
  type t =
    { position : string
    ; result : int
    }

  val parse_exn : string -> t

  val make_position
    :  t
    -> height:int
    -> width:int
    -> (module Position.S with type t = 'p)
    -> 'p
end

module Test_file : sig
  type t =
    { basename : string
    ; test_lines : Test_line.t Array.t
    }

  val load_exn : filename:string -> t
end

type t

val bench : (module Position.S) -> filenames:string list -> debug:bool -> t
val to_ascii_table : t -> string
