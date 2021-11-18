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

(* alpha-beta introduces a score window [alpha;beta] within which you
   search the actual score of a position. It relaxes the constraint of
   computing the exact score whenever the actual score is not within
   the search windows:

   - If the actual score of the position is within the range, than the
   alpha-beta function should return the exact score.

   - If the actual score of the position lower than alpha, than the
   alpha-beta function is allowed to return any upper bound of the
   actual score that is lower or equal to alpha.

   - If the actual score of the position greater than beta, than the
   alpha-beta function is allowed to return any lower bound of the
   actual score that is greater or equal to beta. *)

let negamax_alpha_beta (type t) (module P : Position.S with type t = t) (t : t) ~weak =
  let height = P.height t in
  let width = P.width t in
  let moves = Array.init width ~f:Fn.id in
  let number_of_positions = ref 0 in
  let rec negamax t ~alpha ~beta =
    incr number_of_positions;
    (* Check for draw. *)
    if P.number_of_plies t = height * width
    then 0
    else if Array.exists moves ~f:(fun column ->
                (* Check if current player can win next move. *)
                P.can_play t ~column && P.is_winning_move t ~column)
    then ((width * height) + 1 - P.number_of_plies t) / 2
    else (
      let max =
        (* Upper bound of our score as we cannot win immediately. *)
        ((width * height) - 1 - P.number_of_plies t) / 2
      in
      let beta =
        (* There is no need to keep beta above our max possible score. *)
        if beta > max then max else beta
      in
      if alpha >= beta
      then (* Prune the exploration if the [alpha;beta] window is empty. *)
        beta
      else (
        (* Compute the score of all possible next move and keep the best one. *)
        let rec iter alpha index =
          if index >= Array.length moves
          then alpha
          else (
            let column = moves.(index) in
            match P.can_play t ~column with
            | false -> iter alpha (Int.succ index)
            | true ->
              let t = P.copy t in
              P.play t ~column;
              (* Explore opponent's score within [-beta;-alpha] windows. *)
              let score = -1 * negamax t ~alpha:(-1 * beta) ~beta:(-1 * alpha) in
              (* No need to have good precision for score better than
                 beta (opponent's score worse than -beta).

                 No need to check for score worse than alpha
                 (opponent's score better than -alpha). *)
              if score >= beta
              then
                (* Prune the exploration if we find a possible move
                   better than what we were looking for. *)
                score
              else (
                let alpha =
                  if score > alpha
                  then
                    (* Reduce the [alpha;beta] window for next
                       exploration, as we only need to search for a
                       position that is better than the best so far.
                       *)
                    score
                  else alpha
                in
                iter alpha (Int.succ index)))
        in
        iter alpha 0))
  in
  let t1 = Time.now () in
  let result =
    if weak
    then negamax t (-1) 1
    else negamax t (-1 * height * width / 2) (height * width / 2)
  in
  let t2 = Time.now () in
  { measure =
      { Measure.span = Time.diff t2 t1; number_of_positions = !number_of_positions }
  ; result
  }
;;
