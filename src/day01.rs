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
  let nrun = 10000;

  for _ in 0..nrun {
    let mut input_puzzle = Vec::new();
    let mut one_elf = 0;
    for line in std::fs::read_to_string(filename)?.lines() {
      let line_str = line;
      if line_str.is_empty() {
        input_puzzle.push(one_elf);
        one_elf = 0;
        continue;
      }
      let value = line_str.parse::<u64>()?;
      one_elf += value;
    }
    // Push last elf inventory if the puzzle don't end with new line
    if one_elf != 0 {
      input_puzzle.push(one_elf);
    }

    input_puzzle.sort();
    input_puzzle.reverse();

    part1 = input_puzzle[0];
    part2 = input_puzzle[0..3].iter().sum();
  }
  let duration = now.elapsed().as_micros();
  println!(
    "day01 in {:>8.2} us : part1={:<10} part2={:<10}",
    duration as f32 / nrun as f32,
    part1,
    part2
  );

  Ok(())
}
