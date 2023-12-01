use std::time::Instant;
use std::iter::zip;

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
  let nrun = 10000;

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
      let digits_string = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"];
      'outer: for i in 0..line_len {
        let slice = &line_str[i..];
        if let Some(d) = slice.chars().nth(0).ok_or("Failed to get first digit")?.to_digit(10) {
          parsed_line.push(d as u64);
        } else {
          for (num, str) in zip(1.., digits_string.iter()) {
            if slice.starts_with(str) {
              parsed_line.push(num);
              continue 'outer;
            }
          }
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
