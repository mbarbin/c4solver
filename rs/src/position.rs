pub const HEIGHT: usize = 6;
pub const WIDTH: usize = 7;

// Represent a connect4 game position. Columns are 0-based.
pub trait Position {
    fn key(&self) -> Option<usize>;

    // Create a new position from the given sizes.
    fn create() -> Self;

    /* Return a deep copy of [t], for use in searching algorithm. The
    two positions can diverge freely from there without affecting
    each other. */
    fn copy(&self) -> Self;

    /** The given column can be played if it is not currently completely filled. */
    fn can_play(&self, column: usize) -> bool;

    fn next_player_to_play(&self) -> usize;

    /* Given a free column, place a token of the next player to play
    there. */
    fn play(&mut self, column: usize);

    /* Indicates whether the current player wins by playing in this
    column. */
    fn is_winning_move(&self, column: usize) -> bool;

    /* Return the number of plies that have been played from the
    beginning. This is the number of times [play] has been called. */
    fn number_of_plies(&self) -> usize;

    fn to_ascii_table(&self) -> String;
}

#[derive(Debug, Copy, Clone, PartialEq, PartialOrd)]
#[allow(dead_code)]
pub enum Player {
    Red,
    Yellow,
}

#[derive(Debug, Copy, Clone, PartialEq, PartialOrd)]
#[allow(dead_code)]
pub enum Cell {
    Empty,
    Token { player: Player },
}

pub struct Basic {
    board: [[usize; HEIGHT]; WIDTH],
    height: [usize; WIDTH],
    number_of_plies: usize,
}

impl Position for Basic {
    fn key(&self) -> Option<usize> {
        None // only implemented in Bitboard
    }

    fn create() -> Self {
        let board = {
            let mut board = [[0; HEIGHT]; WIDTH];
            for i in 0..WIDTH {
                board[i] = [0; HEIGHT];
            }
            board
        };
        let height = [0; WIDTH];
        Basic {
            board,
            height,
            number_of_plies: 0,
        }
    }

    fn copy(&self) -> Self {
        let board = {
            let mut board = [[0; HEIGHT]; WIDTH];
            for i in 0..WIDTH {
                board[i] = self.board[i].clone();
            }
            board
        };
        Basic {
            board,
            height: self.height.clone(),
            number_of_plies: self.number_of_plies,
        }
    }

    fn can_play(&self, column: usize) -> bool {
        self.height[column] < HEIGHT
    }

    fn next_player_to_play(&self) -> usize {
        if self.number_of_plies % 2 == 0 {
            1
        } else {
            2
        }
    }

    fn play(&mut self, column: usize) {
        let player = self.next_player_to_play();
        let line = self.height[column];
        self.board[column][line] = player;
        self.height[column] = line + 1;
        self.number_of_plies += 1;
    }

    fn is_winning_move(&self, column: usize) -> bool {
        let current_player = self.next_player_to_play();
        // check for vertical alignments
        if self.height[column] >= 3
            && self.board[column][self.height[column] - 1] == current_player
            && self.board[column][self.height[column] - 2] == current_player
            && self.board[column][self.height[column] - 3] == current_player
        {
            return true;
        }
        for dy in -1..2 {
            // Iterate on horizontal (dy = 0) or two diagonal directions (dy = -1 or dy = 1).
            let mut nb = 0; // counter of the number of stones of current player surronding the played stone in tested direction.
            for dx in [-1, 1] {
                // count continuous stones of current player on the left, then right of the played column.
                let mut x = column as isize + dx;
                let mut y = self.height[column] as isize + dx * dy;
                while x >= 0
                    && x < WIDTH as isize
                    && y >= 0
                    && y < HEIGHT as isize
                    && self.board[x as usize][y as usize] == current_player
                {
                    x += dx;
                    y += dx * dy;
                    nb += 1;
                }
            }
            if nb >= 3 {
                return true;
            }; // there is an aligment if at least 3 other stones of the current user
               // are surronding the played stone in the tested direction.
        }
        return false;
    }

    fn number_of_plies(&self) -> usize {
        self.number_of_plies
    }

    fn to_ascii_table(&self) -> String {
        panic!("Unimplemented");
    }
}

pub fn make<P: Position>(str: &str) -> P {
    let mut p = P::create();
    for (index, char) in str.chars().enumerate() {
        // println!("index, char = {}, {}", index, char);
        let column = (char.to_digit(10).unwrap() - 1) as usize;
        if column >= WIDTH || !(p.can_play(column)) || p.is_winning_move(column) {
            panic!("invalid move {:?} {:?} {:?}", str, index, column)
        } else {
            p.play(column)
        }
    }
    p.copy()
}
