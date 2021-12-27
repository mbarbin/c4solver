mod bench;
mod measure;
mod position;
mod solver;
mod transposition_table;

use crate::position::{Basic, Bitboard};
use crate::transposition_table::Store as Transposition_table;

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
        .arg(
            Arg::with_name("position")
                .long("position")
                .value_name("(bitboard|basic)")
                .help("choose position implementation")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("with_transposition_table")
                .long("with-transposition-table")
                .value_name("BOOL")
                .help("memoize with transposition table")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("iterative_deepening")
                .long("iterative-deepening")
                .value_name("BOOL")
                .help("enable iterative deepening")
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

    let position_kind: position::Kind = {
        match matches.value_of("position") {
            None => position::Kind::Basic,
            Some(str) => position::Kind::parse_exn(str),
        }
    };

    let with_transposition_table: bool = matches
        .value_of("with_transposition_table")
        .unwrap_or("false")
        .parse()
        .expect("with-transposition-table requires boolean");

    let mut transposition_table = if with_transposition_table {
        Some(Transposition_table::create())
    } else {
        None
    };

    let iterative_deepening: bool = matches
        .value_of("iterative_deepening")
        .unwrap_or("false")
        .parse()
        .expect("iterative-deepening requires boolean");

    loop {
        let mut index = String::new();

        io::stdin()
            .read_line(&mut index)
            .expect("Failed to read line");

        let line = index.trim();

        let result: solver::Result = {
            match &position_kind {
                position::Kind::Basic => {
                    let position = position::make::<Basic>(&line);
                    solver::negamax::<Basic>(
                        position,
                        alpha_beta,
                        weak,
                        column_exploration_reorder,
                        &mut transposition_table,
                        iterative_deepening,
                    )
                }
                position::Kind::Bitboard => {
                    let position = position::make::<Bitboard>(&line);
                    solver::negamax::<Bitboard>(
                        position,
                        alpha_beta,
                        weak,
                        column_exploration_reorder,
                        &mut transposition_table,
                        iterative_deepening,
                    )
                }
            }
        };

        println!(
            "{} {} {} {}",
            line,
            result.result,
            result.measure.number_of_positions,
            (result.measure.span.to_int_ns() / 1000) as u64
        )
    }
}
