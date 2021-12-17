use timens::Span;

pub struct Measure {
    pub span: Span,
    pub number_of_positions: usize,
}

#[allow(dead_code)]
pub struct Mean {
    pub span: Span,
    pub number_of_positions: usize,
    pub k_pos_per_s: usize,
}

impl Mean {
    #[allow(dead_code)]
    pub const ZERO: Self = Self {
        span: Span::ZERO,
        number_of_positions: 0,
        k_pos_per_s: 0,
    };

    #[allow(dead_code)]
    pub fn of_measures(measures: &Vec<Measure>) -> Self {
        if measures.is_empty() {
            Mean::ZERO
        } else {
            let mut span = Span::ZERO;
            let mut number_of_positions: usize = 0;
            for measure in measures {
                span += measure.span;
                number_of_positions += measure.number_of_positions;
            }
            let count = measures.len();
            span /= count as i64;
            let number_of_positions: usize =
                (number_of_positions as f64 / count as f64).round() as usize;
            Self {
                span,
                number_of_positions,
                k_pos_per_s: (if !span.is_positive() {
                    0
                } else {
                    (number_of_positions as f64 / span.to_ms() as f64).round() as usize
                }),
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use std::str::FromStr;
    use timens::Span;

    #[test]
    fn mean() {
        let measures = [
            super::Measure {
                span: Span::from_str("1s").unwrap(),
                number_of_positions: 1000000,
            },
            super::Measure {
                span: Span::from_str("2s").unwrap(),
                number_of_positions: 3000000,
            },
        ];
        let mean = super::Mean::of_measures(&measures.into());
        assert!(mean.span == Span::from_str("1.5s").unwrap());
        assert!(mean.number_of_positions == 2000000);
        assert!(mean.k_pos_per_s == 1333);
    }
}
