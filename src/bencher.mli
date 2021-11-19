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

val bench
  :  (module Position.S)
  -> filenames:string list
  -> debug:bool
  -> accuracy_only:bool
  -> alpha_beta:bool
  -> weak:bool
  -> column_exploration_reorder:bool
  -> with_transposition_table:bool
  -> t

val to_ascii_table : t -> string
