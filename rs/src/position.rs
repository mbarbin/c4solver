pub const HEIGHT: usize = 6;
pub const WIDTH: usize = 7;
pub const MIN_SCORE: isize = (-((WIDTH * HEIGHT) as isize) / 2) + 3;

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

impl Basic {
    fn next_player_to_play(&self) -> usize {
        if self.number_of_plies % 2 == 0 {
            1
        } else {
            2
        }
    }
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

pub struct Bitboard {
    number_of_plies: usize,
    position: usize,
    mask: usize,
}

impl Bitboard {
    fn key(&self) -> usize {
        self.position + self.mask
    }

    fn top_mask_col(column: usize) -> usize {
        1 << (HEIGHT - 1 + (column * (HEIGHT + 1)))
    }

    fn bottom_mask_col(column: usize) -> usize {
        1 << (column * (HEIGHT + 1))
    }

    fn column_mask(column: usize) -> usize {
        ((1 << HEIGHT) - 1) << (column * (HEIGHT + 1))
    }

    fn move_mask(&self, column: usize) -> usize {
        (self.mask + Bitboard::bottom_mask_col(column)) & Bitboard::column_mask(column)
    }

    fn alignment(pos: usize) -> bool {
        // horizontal
        let mut m = pos & (pos >> (HEIGHT + 1));
        if 0 != (m & (m >> (2 * (HEIGHT + 1)))) {
            return true;
        };

        // diagonal 1
        m = pos & (pos >> HEIGHT);
        if 0 != (m & (m >> (2 * HEIGHT))) {
            return true;
        };

        // diagonal 2
        m = pos & (pos >> (HEIGHT + 2));
        if 0 != (m & (m >> (2 * (HEIGHT + 2)))) {
            return true;
        };

        // vertical;
        m = pos & (pos >> 1);
        if 0 != (m & (m >> 2)) {
            return true;
        };

        return false;
    }

    #[allow(dead_code)]
    fn cell_mask(column: usize, line: usize) -> usize {
        1 << ((column * (HEIGHT + 1)) + line)
    }
}

impl Position for Bitboard {
    fn key(&self) -> Option<usize> {
        Some(self.key())
    }

    fn create() -> Self {
        Self {
            number_of_plies: 0,
            position: 0,
            mask: 0,
        }
    }

    fn copy(&self) -> Self {
        Self {
            number_of_plies: self.number_of_plies,
            position: self.position,
            mask: self.mask,
        }
    }

    fn can_play(&self, column: usize) -> bool {
        0 == self.mask & Bitboard::top_mask_col(column)
    }

    fn play(&mut self, column: usize) {
        let move_mask = self.move_mask(column);
        self.position = self.position ^ self.mask;
        self.mask = self.mask | move_mask;
        self.number_of_plies += 1;
    }

    fn is_winning_move(&self, column: usize) -> bool {
        let position = self.position ^ self.move_mask(column);
        Bitboard::alignment(position)
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

pub enum Kind {
    Basic,
    Bitboard,
}

impl Kind {
    pub fn parse_exn(str: &str) -> Self {
        match str {
            "basic" | "Basic" => Kind::Basic,
            "bitboard" | "Bitboard" => Kind::Bitboard,
            _ => panic!("Invalid str Kind, expect Basic|Bitboard, got {}", str),
        }
    }
}
