// Represent a connect4 game position. Columns are 0-based.
pub trait Position {
    fn width(&self) -> u8;
    fn height(&self) -> u8;
    fn key(&self) -> Option<usize>;

    // Create a new position from the given sizes.
    fn create(width: u8, height: u8) -> Self;

    /* Return a deep copy of [t], for use in searching algorithm. The
    two positions can diverge freely from there without affecting
    each other. */
    fn copy(&self) -> Self;

    /** The given column can be played if it is not currently completely filled. */
    fn can_play(&self, column: u8) -> bool;

    fn next_player_to_play(&self) -> Player;

    /* Given a free column, place a token of the next player to play
    there. */
    fn play(&mut self, column: u8);

    /* Indicates whether the current player wins by playing in this
    column. */
    fn is_winning_move(&self, column: u8) -> bool;

    /* Return the number of plies that have been played from the
    beginning. This is the number of times [play] has been called. */
    fn number_of_plies(&self) -> usize;

    fn to_ascii_table(&self) -> String;
}

#[derive(Debug, Copy, Clone, PartialEq, PartialOrd)]
pub enum Player {
    Red,
    Yellow,
}

#[derive(Debug, Copy, Clone, PartialEq, PartialOrd)]
pub enum Cell {
    Empty,
    Token { player: Player },
}

pub struct Basic {
    board: Vec<Vec<Cell>>,
    height: Vec<usize>,
    number_of_plies: usize,
}

mod is_winning {
    pub const TRIALS: [((i8, i8), (i8, i8)); 4] = {
        let vertical = (0, -1);
        let left_horizontal = (-1, 0);
        let right_horizontal = (1, 0);
        let left_south_west_north_east_diagonal = (-1, -1);
        let right_south_west_north_east_diagonal = (1, 1);
        let left_north_west_south_east_diagonal = (-1, 1);
        let right_north_west_south_east_diagonal = (1, -1);

        [
            (vertical, (0, 1)),
            (left_horizontal, right_horizontal),
            (
                left_south_west_north_east_diagonal,
                right_south_west_north_east_diagonal,
            ),
            (
                left_north_west_south_east_diagonal,
                right_north_west_south_east_diagonal,
            ),
        ]
    };
}

impl Basic {
    fn is_winning_count(
        &self,
        width: i8,
        height: i8,
        cell: &Cell,
        acc: usize,
        (x, y): (i8, i8),
        (dx, dy): (i8, i8),
    ) -> usize {
        if acc >= 3 {
            acc
        } else {
            let x = x + dx;
            let y = y + dy;
            if x < 0
                || y < 0
                || x >= width
                || y >= height
                || *cell != self.board[x as usize][y as usize]
            {
                acc
            } else {
                self.is_winning_count(width, height, cell, acc + 1, (x, y), (dx, dy))
            }
        }
    }
}

impl Position for Basic {
    fn width(&self) -> u8 {
        self.board.len() as u8
    }
    fn height(&self) -> u8 {
        if self.width() == 0 {
            0
        } else {
            self.board[0].len() as u8
        }
    }
    fn key(&self) -> Option<usize> {
        None // only implemented in Bitboard
    }

    fn create(width: u8, height: u8) -> Self {
        let mut board = Vec::new();
        for _ in 0..width {
            let mut vec = Vec::new();
            for _ in 0..height {
                vec.push(Cell::Empty);
            }
            board.push(vec);
        }
        let mut height = Vec::new();
        for _ in 0..width {
            height.push(0);
        }
        Basic {
            board,
            height,
            number_of_plies: 0,
        }
    }

    fn copy(&self) -> Self {
        let mut board = Vec::new();
        for i in 0..self.width() {
            let mut vec = Vec::new();
            for j in 0..self.height() {
                vec.push(self.board[i as usize][j as usize]);
            }
            board.push(vec);
        }
        Basic {
            board,
            height: self.height.clone(),
            number_of_plies: self.number_of_plies,
        }
    }

    fn can_play(&self, column: u8) -> bool {
        self.height[column as usize] < self.height() as usize
    }

    fn next_player_to_play(&self) -> Player {
        if self.number_of_plies % 2 == 0 {
            Player::Red
        } else {
            Player::Yellow
        }
    }

    fn play(&mut self, column: u8) {
        let player = self.next_player_to_play();
        let line = self.height[column as usize];
        self.board[column as usize][line] = Cell::Token { player };
        self.height[column as usize] = line + 1;
        self.number_of_plies += 1;
    }

    fn is_winning_move(&self, column: u8) -> bool {
        let width = self.width();
        let height = self.height();
        let player = self.next_player_to_play();
        let cell = Cell::Token { player };
        let line = self.height[column as usize];
        for (left, right) in is_winning::TRIALS {
            let acc = self.is_winning_count(
                width as i8,
                height as i8,
                &cell,
                0,
                (column as i8, line as i8),
                left,
            );
            let acc = self.is_winning_count(
                width as i8,
                height as i8,
                &cell,
                acc,
                (column as i8, line as i8),
                right,
            );
            if acc >= 3 {
                return true;
            }
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

pub fn make<P: Position>(str: &str, width: u8, height: u8) -> P {
    let mut p = P::create(width, height);
    for (index, char) in str.chars().enumerate() {
        // println!("index, char = {}, {}", index, char);
        let column: u8 = (char.to_digit(10).unwrap() - 1) as u8;
        if column >= width || !(p.can_play(column)) || p.is_winning_move(column) {
            panic!("invalid move {:?} {:?} {:?}", str, index, column)
        } else {
            p.play(column)
        }
    }
    p.copy()
}
