use crate::position::{self, Position};

#[derive(Debug)]
#[allow(dead_code)]
struct TestLine {
    position: String,
    result: isize,
}

impl TestLine {
    #[allow(dead_code)]
    fn parse_exn(str: &str) -> Self {
        let v: Vec<&str> = str.split(' ').collect();
        let position = String::from(v[0]);
        let result: isize = v[1]
            .parse()
            .expect("expect second component of line to be a number");
        TestLine { position, result }
    }

    #[allow(dead_code)]
    fn make_position<P: Position>(&self, height: u8, width: u8) -> P {
        position::make::<P>(&self.position, height, width)
    }
}
