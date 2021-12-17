mod bench;
mod measure;
mod position;
mod solver;

use crate::position::Basic;
use std::io;

const HEIGHT: u8 = 6;
const WIDTH: u8 = 7;

fn main() {
    loop {
        let mut index = String::new();

        io::stdin()
            .read_line(&mut index)
            .expect("Failed to read line");

        let line = index.trim();

        let position = position::make::<Basic>(&line, WIDTH, HEIGHT);
        let result = solver::negamax(position);
        println!(
            "{} {} {} {}",
            line,
            result.result,
            result.measure.number_of_positions,
            (result.measure.span.to_int_ns() / 1000) as u64
        )
    }
}