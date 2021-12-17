use crate::measure::Measure;
use crate::position::Position;
use timens::Time;

struct Env<'a> {
    width: isize,
    height: isize,
    moves: &'a Vec<u8>,
    number_of_positions: usize,
}

impl<'a> Env<'a> {
    fn negamax<P: Position>(&mut self, position: P) -> isize {
        self.number_of_positions += 1;
        /* Check for draw. */
        if position.number_of_plies() as isize == self.height * self.width {
            0
        } else {
            for &column in self.moves {
                /* Check if current player can win next move. */
                if position.can_play(column) && position.is_winning_move(column) {
                    return ((self.width * self.height) + 1 - position.number_of_plies() as isize)
                        / 2;
                }
            }
            /* Init the best possible score with a lower bound. */
            let mut best_score = -1 * self.width * self.height;
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
    let width = position.width() as isize;
    let height = position.height() as isize;
    let moves = {
        let mut vec = Vec::new();
        for i in 0..width {
            vec.push(i as u8)
        }
        vec
    };
    let number_of_positions = 0;
    let mut env = Env {
        width,
        height,
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
