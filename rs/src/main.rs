mod measure;
mod position;
mod solver;
mod step;
mod transposition_table;

use crate::position::{Basic, Bitboard};
use crate::step::Step;
use crate::transposition_table::Store as Transposition_table;

use std::io;

extern crate clap;
use clap::{Arg, Command};

fn main() {
    let matches = Command::new("c4solver")
        .arg(
            Arg::new("step")
                .long("step")
                .value_name("STEP")
                .help("select solver step")
                .takes_value(true),
        )
        .arg(
            Arg::new("weak")
                .long("weak")
                .help("run weak solver")
                .takes_value(false),
        )
        .get_matches();

    let step: Step = matches
        .value_of("step")
        .unwrap_or("MinMax")
        .parse()
        .expect("step requires Step constructor");

    let params = step.to_params();

    let alpha_beta = params.alpha_beta;
    let weak: bool = matches.is_present("weak");

    let column_exploration_reorder = params.column_exploration_reorder;
    let position_kind = params.position_kind;
    let with_transposition_table = params.with_transposition_table;

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
