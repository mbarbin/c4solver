use crate::measure::Measure;
use crate::position::{self, Position};
use timens::Time;

struct Env<'a> {
    moves: &'a Vec<u8>,
    number_of_positions: usize,
}

impl<'a> Env<'a> {
    fn negamax<P: Position>(&mut self, position: P) -> isize {
        self.number_of_positions += 1;
        /* Check for draw. */
        if position.number_of_plies() == (position::WIDTH * position::HEIGHT) as usize {
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
}

pub struct Result {
    pub measure: Measure,
    pub result: isize,
}

pub fn negamax<P: Position>(position: P) -> Result {
    let moves = {
        let mut vec = Vec::new();
        for i in 0..position::WIDTH {
            vec.push(i as u8)
        }
        vec
    };
    let number_of_positions = 0;
    let mut env = Env {
        moves: &moves,
        number_of_positions,
    };
    let t1 = Time::now();
    let result = env.negamax(position);
    let t2 = Time::now();
    Result {
        measure: Measure {
            span: (t2 - t1),
            number_of_positions: env.number_of_positions,
        },
        result,
    }
}
