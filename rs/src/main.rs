mod bench;
mod measure;
mod position;
mod solver;

use crate::position::Basic;
use std::io;

extern crate clap;
use clap::{App, Arg};

fn main() {
    let matches = App::new("c4solver")
        .arg(
            Arg::with_name("alpha_beta")
                .long("alpha-beta")
                .value_name("BOOL")
                .help("enable alpha-beta pruning")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("weak")
                .long("weak")
                .help("run weak solver")
                .takes_value(false),
        )
        .arg(
            Arg::with_name("column_exploration_reorder")
                .long("column-exploration-reorder")
                .value_name("BOOL")
                .help("explore with center column first")
                .takes_value(true),
        )
        .get_matches();

    let alpha_beta: bool = matches
        .value_of("alpha_beta")
        .unwrap_or("true")
        .parse()
        .expect("alpha-beta requires boolean");

    let weak: bool = matches.is_present("weak");

    let column_exploration_reorder: bool = matches
        .value_of("column_exploration_reorder")
        .unwrap_or("true")
        .parse()
        .expect("column-exploration-reorder requires boolean");

    loop {
        let mut index = String::new();

        io::stdin()
            .read_line(&mut index)
            .expect("Failed to read line");

        let line = index.trim();

        let position = position::make::<Basic>(&line);
        let result = solver::negamax(position, alpha_beta, weak, column_exploration_reorder);
        println!(
            "{} {} {} {}",
            line,
            result.result,
            result.measure.number_of_positions,
            (result.measure.span.to_int_ns() / 1000) as u64
        )
    }
}
