use crate::position::Kind as Position_kind;
use enum_utils;

pub struct Params {
    pub position_kind: Position_kind,
    pub alpha_beta: bool,
    pub column_exploration_reorder: bool,
    pub with_transposition_table: bool,
    pub iterative_deepening: bool,
}

#[derive(Debug, enum_utils::FromStr)]
pub enum Step {
    MinMax,
    AlphaBeta,
    ColumnExplorationOrder,
    Bitboard,
    TranspositionTable,
    IterativeDeepening,
}

impl Step {
    pub fn to_params(&self) -> Params {
        match self {
            Step::MinMax => Params {
                position_kind: Position_kind::Basic,
                alpha_beta: false,
                column_exploration_reorder: false,
                with_transposition_table: false,
                iterative_deepening: false,
            },
            Step::AlphaBeta => Params {
                position_kind: Position_kind::Basic,
                alpha_beta: true,
                column_exploration_reorder: false,
                with_transposition_table: false,
                iterative_deepening: false,
            },
            Step::ColumnExplorationOrder => Params {
                position_kind: Position_kind::Basic,
                alpha_beta: true,
                column_exploration_reorder: true,
                with_transposition_table: false,
                iterative_deepening: false,
            },
            Step::Bitboard => Params {
                position_kind: Position_kind::Bitboard,
                alpha_beta: true,
                column_exploration_reorder: true,
                with_transposition_table: false,
                iterative_deepening: false,
            },
            Step::TranspositionTable => Params {
                position_kind: Position_kind::Bitboard,
                alpha_beta: true,
                column_exploration_reorder: true,
                with_transposition_table: true,
                iterative_deepening: false,
            },
            Step::IterativeDeepening => Params {
                position_kind: Position_kind::Bitboard,
                alpha_beta: true,
                column_exploration_reorder: true,
                with_transposition_table: true,
                iterative_deepening: true,
            },
        }
    }
}
