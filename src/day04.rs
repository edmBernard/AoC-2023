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
    let mut acc_part1 = 0;
    let mut acc_part2 = 0;
    for line in std::fs::read_to_string(filename)?.lines() {
      let line_str = line;
      // part1
      {
        // we can do the part1 with a range notation (filter_map) but it's super slow
        let mut first_digits = 0;
        let mut last_digits = 0;
        'forward: for i in 0..line_str.len() {
          let slice = &line_str[i..];
          if let Some(d) = slice.chars().next().ok_or("Failed to get first char")?.to_digit(10) {
            first_digits = d;
            break 'forward;
          }
        }
        'backward: for i in (0..line_str.len()).rev() {
          let slice = &line_str[i..];
          if let Some(d) = slice.chars().next().ok_or("Failed to get first char")?.to_digit(10) {
            last_digits = d;
            break 'backward;
          }
        }
        acc_part1 += first_digits * 10 + last_digits;
      }
      // part2
      {
        let mut first_digits = 0;
        let mut last_digits = 0;
        // We use this method because word can overlap like "nineight"
        let digits_string = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"];
        'forward: for i in 0..line_str.len() {
          let slice = &line_str[i..];
          if let Some(d) = slice.chars().next().ok_or("Failed to get first char")?.to_digit(10) {
              first_digits = d;
              break 'forward;
          } else {
            for (idx, str) in digits_string.iter().enumerate() {
              if slice.starts_with(str) {
                first_digits = (idx + 1) as u32;
                break 'forward;
              }
            }
          }
        }
        'backward: for i in (0..line_str.len()).rev() {
          let slice = &line_str[i..];
          if let Some(d) = slice.chars().next().ok_or("Failed to get first char")?.to_digit(10) {
            last_digits = d;
              break 'backward;
          } else {
            for (idx, str) in digits_string.iter().enumerate() {
              if slice.starts_with(str) {
                last_digits = (idx + 1) as u32;
                break 'backward;
              }
            }
          }
        }
        acc_part2 += first_digits * 10 + last_digits;
      }
    }
    part1 = acc_part1 as u64;
    part2 = acc_part2 as u64;
  }
  let duration = now.elapsed().as_micros();
  println!(
    "info: Rust day04 in {:>20.2} us : part1={:<10} part2={:<10}",
    duration as f32 / nrun as f32,
    part1,
    part2
  );

  Ok(())
}
