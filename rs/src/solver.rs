use crate::measure::Measure;
use crate::position::{self, Position};
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
            if beta > max {
                beta = max; // there is no need to keep beta above our max possible score.

                if alpha >= beta {
                    return beta;
                }
            }; // prune the exploration if the [alpha;beta] window is empty.

            for &column in self.moves {
                /* Compute the score of all possible next move and keep the best one. */
                if position.can_play(column) {
                    let mut position = position.copy();
                    position.play(column);
                    /* The turn in the copy of t is the opponent. If the
                    current player has played col, their score will be
                    the opposite of the score from the opponent's
                    perspective. */
                    let score = -1 * self.negamax_alpha_beta(position, -beta, -alpha);
                    // no need to have good precision for score better than beta (opponent's score worse than -beta)
                    // no need to check for score worse than alpha (opponent's score worse better than -alpha)
                    if score >= beta {
                        return score;
                    }; // prune the exploration if we find a possible move better than what we were looking for.
                    if score > alpha {
                        alpha = score
                    }; // reduce the [alpha;beta] window for next exploration, as we only
                       // need to search for a position that is better than the best so far.
                }
            }
            return alpha;
        }
    }
}

pub struct Result {
    pub measure: Measure,
    pub result: isize,
}

pub fn negamax<P: Position>(position: P, alpha_beta: bool, weak: bool) -> Result {
    let moves = {
        let mut moves = [0; position::WIDTH];
        for i in 0..position::WIDTH {
            moves[i] = i
        }
        moves
    };
    let number_of_positions = 0;
    let mut env = Env {
        moves: &moves,
        number_of_positions,
    };
    let t1 = Time::now();
    let result = {
        if !alpha_beta {
            env.negamax(position)
        } else if weak {
            env.negamax_alpha_beta(position, -1, 1)
        } else {
            env.negamax_alpha_beta(
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
