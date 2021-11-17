open! Core

type t =
  { measure : Measure.t
  ; result : int
  }

let negamax (type t) (module P : Position.S with type t = t) (t : t) =
  let height = P.height t in
  let width = P.width t in
  let moves = Array.init width ~f:Fn.id in
  let number_of_positions = ref 0 in
  let rec negamax t =
    incr number_of_positions;
    (* Check for draw. *)
    if P.number_of_plies t = height * width
    then 0
    else if Array.exists moves ~f:(fun column ->
                (* Check if current player can win next move. *)
                P.can_play t ~column && P.is_winning_move t ~column)
    then ((width * height) + 1 - P.number_of_plies t) / 2
    else (
      (* Init the best possible score with a lower bound. *)
      let best_score = ref (-1 * width * height) in
      Array.iter moves ~f:(fun column ->
          (* Compute the score of all possible next move and keep the best one. *)
          if P.can_play t ~column
          then (
            let t = P.copy t in
            P.play t ~column;
            (* The turn in the copy of t is the opponent. If the
                 current player has played col, their score will be
                 the opposite of the score from the opponent's
                 perspective. *)
            let score = -1 * negamax t in
            (* Keep track of the best possible score so far. *)
            if score > !best_score then best_score := score));
      !best_score)
  in
  let t1 = Time.now () in
  let result = negamax t in
  let t2 = Time.now () in
  { measure =
      { Measure.span = Time.diff t2 t1; number_of_positions = !number_of_positions }
  ; result
  }
;;
