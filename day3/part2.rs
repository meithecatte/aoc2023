use std::fs::read_to_string;
use std::path::Path;
use std::collections::BTreeSet;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Square {
    Dot,
    Symbol(char),
    Number(usize),
}

#[derive(Clone, Debug)]
struct InputData {
    numbers: Vec<u32>,
    map: Vec<Vec<Square>>,
}

impl InputData {
    fn neighbours(&self, r: usize, c: usize) -> impl Iterator<Item=Square> + '_ {
        (r.saturating_sub(1)..=r + 1)
            .filter_map(move |i| self.map.get(i))
            .flat_map(move |row| {
                (c.saturating_sub(1)..=c + 1)
                    .filter_map(move |j| row.get(j))
                    .copied()
            })
    }
}

fn parse(path: impl AsRef<Path>) -> InputData {
    let input = read_to_string(path).unwrap();
    let mut numbers = vec![];
    let mut map = vec![];

    for mut line in input.lines() {
        let mut row = vec![];
        while !line.is_empty() {
            if line.starts_with(|c: char| c.is_ascii_digit()) {
                let k = line.find(|c: char| !c.is_ascii_digit()).unwrap_or(line.len());
                let (num, rest) = line.split_at(k);
                for _ in 0..k {
                    row.push(Square::Number(numbers.len()));
                }

                numbers.push(num.parse().unwrap());
                line = rest;
            } else {
                match line.chars().next().unwrap() {
                    '.' => row.push(Square::Dot),
                    c => row.push(Square::Symbol(c)),
                }

                line = &line[1..];
            }
        }

        map.push(row);
    }

    InputData { numbers, map }
}

fn part2(input: InputData) -> u64 {
    let mut total = 0;

    for (i, row) in input.map.iter().enumerate() {
        for (j, square) in row.iter().copied().enumerate() {
            if square == Square::Symbol('*') {
                let numbers = input.neighbours(i, j)
                    .filter_map(|sq| match sq {
                        Square::Number(i) => Some(i),
                        _ => None,
                    })
                    .collect::<BTreeSet<usize>>();
                if numbers.len() == 2 {
                    total += numbers.into_iter()
                        .map(|i| input.numbers[i] as u64)
                        .product::<u64>();
                }
            }
        }
    }

    total
}

fn main() {
    println!("input.example: {}", part2(parse("input.example")));
    println!("input: {}", part2(parse("input")));
}
