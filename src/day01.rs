use regex::Regex;
use std::time::Instant;

type Result<T> = ::std::result::Result<T, Box<dyn (::std::error::Error)>>;

fn main() -> Result<()> {
  let args: Vec<String> = std::env::args().collect();
  if args.len() <= 1 {
    Err("Missing filename")?;
  }
  let filename = &args[1];

  let now = Instant::now();

  let mut part1: u64 = 0;
  let mut part2: u64 = 0;
  let nrun = 100;

  for _ in 0..nrun {
    let mut digits1: Vec<i32> = Vec::new();
    let mut digits2: Vec<u64> = Vec::new();
    for line in std::fs::read_to_string(filename)?.lines() {
      let line_str = line;
      // part1
      let parsed_line: Vec<i32> = line_str
        .as_bytes()
        .iter()
        .map(|c| *c as i32 - '0' as i32)
        .filter(|d| *d >= 0 && *d < 10i32)
        .collect::<Vec<_>>();
      let parsed_len = parsed_line.len();
      if parsed_len > 0 {
        digits1.push(parsed_line[0] * 10 + parsed_line[parsed_len - 1]);
      }
      // part2
      let mut parsed_line: Vec<u64> = vec![];
      let line_len = line_str.len();
      // We use this method because word can overlap like "nineight"
      for i in 0..line_len {
        let slice = &line_str[i..];
        if let Some(d) = slice.chars().nth(0).unwrap().to_digit(10) {
          println!("slice {}", slice);
          parsed_line.push(d as u64);
        } else if slice.starts_with("one") {
            parsed_line.push(1);
        } else if slice.starts_with("two") {
            parsed_line.push(2);
        } else if slice.starts_with("three") {
            parsed_line.push(3);
        } else if slice.starts_with("four") {
            parsed_line.push(4);
        } else if slice.starts_with("five") {
            parsed_line.push(5);
        } else if slice.starts_with("six") {
            parsed_line.push(6);
        } else if slice.starts_with("seven") {
            parsed_line.push(7);
        } else if slice.starts_with("eight") {
            parsed_line.push(8);
        } else if slice.starts_with("nine") {
            parsed_line.push(9);
        }
      }
      let parsed_len = parsed_line.len();
      digits2.push(parsed_line[0] * 10 + parsed_line[parsed_len - 1]);
    }
    part1 = digits1.iter().sum::<i32>() as u64;
    part2 = digits2.iter().sum();
  }
  let duration = now.elapsed().as_micros();
  println!(
    "info: Rust day01 in {:>20.2} us : part1={:<10} part2={:<10}",
    duration as f32 / nrun as f32,
    part1,
    part2
  );

  Ok(())
}
