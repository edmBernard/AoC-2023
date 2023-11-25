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

| Day   | Description                | Tips  |
|--     |--                          |--     |
| Day01 [<sup>puzzle</sup>](https://adventofcode.com/2023/day/1 ) [<sup>solution</sup>](src/day01.zig) | Max of range                 | -     |


## Some Timing :

```
In Zig
day01     in   +66 us : part1=43554      part2=139877

In C++
day01_speed_iter        in 37.0242 us : part1=70720     part2=207148

In Rust
day01 in    33.67 us : part1=70720      part2=207148
```

## Versions

Zig : 0.11.0
Rust : rustc 1.70.0
C++ : clang 15.0.0
