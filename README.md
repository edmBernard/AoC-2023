# AoC-2023

My solutions to [Advent of Code 2023](https://adventofcode.com/). This year, I'm going to try doing the challenges mainly in [Zig](https://ziglang.org//) and [Rust](https://rustlang.org//)

- Github : [https://github.com/edmBernard/AoC-2023](https://github.com/edmBernard/AoC-2023)

## Getting Started

```bash
git clone git@github.com:edmBernard/AoC-2023.git
cd AoC-2023
zig build -Drelease
cargo build --release
```

## Run

```bash
./zig-out/bin/day01 data/day01.txt
./target/release/day01 data/day01.txt
```

## Problem

| Day   | Solution | Description                | Tips  |
|--     |--        |--                          |--     |
| Day01 <sup>[puzzle](https://adventofcode.com/2023/day/1) | [Zig](src/day01.zig) [Rust](src/day01.rs) [C++](src/day01.cpp) | Find digit and literal digit | Store only useful digits, do the search in both direction, digit name can overlap |
| Day02 <sup>[puzzle](https://adventofcode.com/2023/day/2) | [Zig](src/day02.zig) | Find number of colored cube |  |
| Day03 <sup>[puzzle](https://adventofcode.com/2023/day/3) | [Zig](src/day03.zig) | Find engine part and gear | nothing just hard |
| Day04 <sup>[puzzle](https://adventofcode.com/2023/day/4) | [Zig](src/day04.zig) | Scratch card |  |
| Day05 <sup>[puzzle](https://adventofcode.com/2023/day/5) | [Zig](src/day05.zig) | Seeds planting | directly work on range |
| Day06 <sup>[puzzle](https://adventofcode.com/2023/day/6) | [Zig](src/day06.zig) | Boat race |  |
| Day07 <sup>[puzzle](https://adventofcode.com/2023/day/7) | [Zig](src/day07.zig) | Poker |  |
| Day08 <sup>[puzzle](https://adventofcode.com/2023/day/8) | [Zig](src/day08.zig) | Graph | inputs are particular enough to use LCM |
| Day11 <sup>[puzzle](https://adventofcode.com/2023/day/11) | [Zig](src/day11.zig) | Galaxy and universe expansion | work directly on galaxy coordinate |


## Some Timing :

```
In Zig
Zig  day01 in                64.88 us : part1=54304      part2=54418
Zig  day02 in                44.50 us : part1=2348       part2=76008
Zig  day03 in               117.06 us : part1=527364     part2=79026871
Zig  day04 in                82.68 us : part1=21558      part2=10425665
Zig  day05 in                50.07 us : part1=600279879  part2=20191102
Zig  day06 in                 8.45 us : part1=114400     part2=21039729
Zig  day07 in              1964.08 us : part1=250946742  part2=251824095
Zig  day08 in              3258.56 us : part1=22357      part2=10371555451871
...
Zig  day11 in               156.32 us : part1=9599070    part2=842645913794

In Rust
Rust day01 in                66.89 us : part1=54304      part2=54418

In C++
C++  day01 in               49.191 us : part1=54304     part2=54418

```

## Versions

- Zig  : 0.11.0
- Rust : rustc 1.76.0
- C++  : clang 15.0.0
