use crate::measure::Measure;
use crate::position::{self, Position};
use crate::transposition_table::Store as Transposition_table;
use timens::Time;

struct Env<'a> {
    moves: &'a [usize; position::WIDTH],
    number_of_positions: usize,
}

impl<'a> Env<'a> {
    fn negamax<P: Position>(&mut self, position: P) -> isize {
        self.number_of_positions += 1;
        /* Check for draw. */
        if position.number_of_plies() == position::WIDTH * position::HEIGHT {
            0
        } else {
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
                    let score = -1 * self.negamax(position);
                    /* Keep track of the best possible score so far. */
                    if score > best_score {
                        best_score = score
                    };
                }
            }
            best_score
        }
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
    fn negamax_alpha_beta<P: Position>(
        &mut self,
        position: P,
        mut alpha: isize,
        mut beta: isize,
        transposition_table: &mut Option<Transposition_table>,
    ) -> isize {
        self.number_of_positions += 1;
        /* Check for draw. */
        if position.number_of_plies() == position::WIDTH * position::HEIGHT {
            0
        } else {
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
                match transposition_table {
                    Some(_) => position.key().unwrap(),
                    None => 0,
                }
            };

            let max = {
                match transposition_table {
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
                    let score =
                        -1 * self.negamax_alpha_beta(position, -beta, -alpha, transposition_table);
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
            match transposition_table {
                None => {}
                Some(transposition_table) => {
                    transposition_table.put(key, (alpha - position::MIN_SCORE + 1) as usize);
                }
            };
            return alpha;
        }
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
    let number_of_positions = 0;
    let mut env = Env {
        moves: &moves,
        number_of_positions,
    };
    match transposition_table {
        None => {}
        Some(transposition_table) => transposition_table.reset(),
    };
    let t1 = Time::now();
    let result = {
        if !alpha_beta {
            env.negamax(position)
        } else if weak {
            env.negamax_alpha_beta(position, -1, 1, transposition_table)
        } else {
            env.negamax_alpha_beta(
                position,
                -((position::WIDTH * position::HEIGHT) as isize) / 2,
                (position::WIDTH * position::HEIGHT) as isize / 2,
                transposition_table,
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
