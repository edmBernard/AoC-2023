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
| Day01 [<sup>puzzle</sup>](https://adventofcode.com/2023/day/1 ) [<sup>solution</sup>](src/day01.zig) | Find digit and literal digit | -     |


## Some Timing :

```
In Zig
Zig  day01 in                64.88 us : part1=54304      part2=54418

In Rust
Rust day01 in               127.08 us : part1=54304      part2=54418

In C++
C++  day01 in               49.191 us : part1=54304     part2=54418

```

## Versions

Zig  : 0.11.0
Rust : rustc 1.76.0
C++  : clang 15.0.0
