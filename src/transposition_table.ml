open! Base

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
  Array.create ~len:size Entry.zero
;;

let reset t =
  for i = 0 to Array.length t - 1 do
    t.(i) <- Entry.zero
  done
;;

let put (t : t) ~key ~data = t.(index t ~key) <- { Entry.key; data }

let get (t : t) ~key =
  let entry = t.(index t ~key) in
  if entry.key = key then entry.data else 0
;;
