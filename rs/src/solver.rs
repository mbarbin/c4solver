use crate::measure::Measure;
use crate::position::{self, Position};
use crate::transposition_table::Store as Transposition_table;
use timens::Time;

struct Env<'a> {
    moves: &'a [usize; position::WIDTH],
    number_of_positions: usize,
    transposition_table: &'a mut Option<Transposition_table>,
}

impl<'a> Env<'a> {
    fn aux_negamax<P: Position>(&mut self, position: P) -> isize {
        self.number_of_positions += 1;
        /* Check for draw. */
        if position.number_of_plies() == position::WIDTH * position::HEIGHT {
            return 0;
        }
        for &column in self.moves {
            /* Check if current player can win next move. */
            if position.can_play(column) && position.is_winning_move(column) {
                return ((position::WIDTH * position::HEIGHT) as isize + 1
                    - position.number_of_plies() as isize)
                    / 2;
            }
        }
        /* Init the best possible score with a lower bound. */
        let mut best_score = -1 * (position::WIDTH * position::HEIGHT) as isize;
        for &column in self.moves {
            /* Compute the score of all possible next move and keep the best one. */
            if position.can_play(column) {
                let mut position = position.copy();
                position.play(column);
                /* The turn in the copy of t is the opponent. If the
                current player has played col, their score will be
                the opposite of the score from the opponent's
                perspective. */
                let score = -1 * self.aux_negamax(position);
                /* Keep track of the best possible score so far. */
                if score > best_score {
                    best_score = score
                };
            }
        }
        best_score
    }

    fn iterative_deepening<P: Position>(&mut self, position: P, weak: bool) -> isize {
        let mut min = -((position::WIDTH * position::HEIGHT) as isize
            - position.number_of_plies() as isize)
            / 2;
        let mut max = ((position::WIDTH * position::HEIGHT) as isize + 1
            - position.number_of_plies() as isize)
            / 2;
        if weak {
            min = -1;
            max = 1;
        }
        while min < max {
            // iteratively narrow the min-max exploration window
            let mut med = min + (max - min) / 2;
            if med <= 0 && min / 2 < med {
                med = min / 2;
            } else if med >= 0 && max / 2 > med {
                med = max / 2;
            };
            // use a null depth window to know if the actual score is greater or smaller than med
            let r = self.aux_negamax_alpha_beta(position.copy(), med, med + 1);
            if r <= med {
                max = r
            } else {
                min = r
            };
        }
        return min;
    }

    /**
     * Reccursively score connect 4 position using negamax variant of alpha-beta algorithm.
     * @param: alpha < beta, a score window within which we are evaluating the position.
     *
     * @return the exact score, an upper or lower bound score depending of the case:
     * - if actual score of position <= alpha then actual score <= return value <= alpha
     * - if actual score of position >= beta then beta <= return value <= actual score
     * - if alpha <= actual score <= beta then return value = actual score
     */
    fn aux_negamax_alpha_beta<P: Position>(
        &mut self,
        position: P,
        mut alpha: isize,
        mut beta: isize,
    ) -> isize {
        self.number_of_positions += 1;
        /* Check for draw. */
        if position.number_of_plies() == position::WIDTH * position::HEIGHT {
            return 0;
        }
        for &column in self.moves {
            /* Check if current player can win next move. */
            if position.can_play(column) && position.is_winning_move(column) {
                return ((position::WIDTH * position::HEIGHT) as isize + 1
                    - position.number_of_plies() as isize)
                    / 2;
            }
        }
        // upper bound of our score as we cannot win immediately
        let max = ((position::WIDTH * position::HEIGHT) as isize
            - 1
            - position.number_of_plies() as isize)
            / 2;

        let key = {
            match self.transposition_table {
                Some(_) => position.key().unwrap(),
                None => 0,
            }
        };

        let max = {
            match self.transposition_table {
                None => max,
                Some(transposition_table) => {
                    let data = transposition_table.get(key);
                    if data > 0 {
                        data as isize + position::MIN_SCORE - 1
                    } else {
                        max
                    }
                }
            }
        };

        if beta > max {
            beta = max; // there is no need to keep beta above our max possible score.
            if alpha >= beta {
                // prune the exploration if the [alpha;beta] window is empty.
                return beta;
            }
        };
        for &column in self.moves {
            /* Compute the score of all possible next move and keep the best one. */
            if position.can_play(column) {
                let mut position = position.copy();
                position.play(column);
                /* The turn in the copy of t is the opponent. If the
                current player has played col, their score will be
                the opposite of the score from the opponent's
                perspective. */
                let score = -1 * self.aux_negamax_alpha_beta(position, -beta, -alpha);
                // no need to have good precision for score better than beta (opponent's score worse than -beta)
                // no need to check for score worse than alpha (opponent's score worse better than -alpha)
                if score >= beta {
                    // prune the exploration if we find a possible move better than what we were looking for.
                    return score;
                };
                if score > alpha {
                    // reduce the [alpha;beta] window for next exploration, as we only
                    // need to search for a position that is better than the best so far.
                    alpha = score
                };
            }
        }
        // Save the upper bound of the position.
        match self.transposition_table {
            None => {}
            Some(transposition_table) => {
                transposition_table.put(key, (alpha - position::MIN_SCORE + 1) as usize);
            }
        };
        return alpha;
    }
}

pub struct Result {
    pub measure: Measure,
    pub result: isize,
}

pub fn negamax<P: Position>(
    position: P,
    alpha_beta: bool,
    weak: bool,
    column_exploration_reorder: bool,
    transposition_table: &mut Option<Transposition_table>,
    iterative_deepening: bool,
) -> Result {
    let moves = {
        let mut moves = [0; position::WIDTH];
        for i in 0..position::WIDTH {
            if column_exploration_reorder {
                // initialize the column exploration order, starting with center columns
                moves[i] = (position::WIDTH as isize / 2
                    + (1 - 2 * (i as isize % 2)) * (i as isize + 1) / 2)
                    as usize;
            } else {
                moves[i] = i;
            }
        }
        moves
    };
    match transposition_table {
        None => {}
        Some(transposition_table) => transposition_table.reset(),
    };
    let mut env = Env {
        moves: &moves,
        number_of_positions: 0,
        transposition_table,
    };
    let t1 = Time::now();
    let result = {
        if !alpha_beta {
            env.aux_negamax(position)
        } else if iterative_deepening {
            env.iterative_deepening(position, weak)
        } else if weak {
            env.aux_negamax_alpha_beta(position, -1, 1)
        } else {
            env.aux_negamax_alpha_beta(
                position,
                -((position::WIDTH * position::HEIGHT) as isize) / 2,
                (position::WIDTH * position::HEIGHT) as isize / 2,
            )
        }
    };
    let t2 = Time::now();
    Result {
        measure: Measure {
            span: (t2 - t1),
            number_of_positions: env.number_of_positions,
        },
        result,
    }
}
