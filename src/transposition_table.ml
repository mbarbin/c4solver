open! Core

module Entry = struct
  type t =
    { key : int
    ; data : int
    }

  let zero = { key = 0; data = 0 }
end

type t = Entry.t Array.t

let index t ~key = key % Array.length t

let create ~size =
  assert (size > 0);
  Array.create size Entry.zero
;;

let put (t : t) ~key ~data = t.(index t ~key) <- { Entry.key; data }

let get (t : t) ~key =
  let entry = t.(index t ~key) in
  if entry.key = key then entry.data else 0
;;
