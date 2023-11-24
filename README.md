# AoC-2023

My solutions to [Advent of Code 2023](https://adventofcode.com/). This year, I'm going to try doing the challenges in completly in [Zig](https://ziglang.org//)

- Github : [https://github.com/edmBernard/AoC-2023](https://github.com/edmBernard/AoC-2023)

## Getting Started

```bash
git clone git@github.com:edmBernard/AoC-2023.git
cd AoC-2023
zig build -Drelease
```

## Run

```bash
./zig-out/bin/day01 data/day01.txt
```

## Problem

| Day   | Description                | Tips  |
|--     |--                          |--     |
| Day01 [<sup>puzzle</sup>](https://adventofcode.com/2023/day/1 ) [<sup>solution</sup>](src/day01.zig) | Max of range                 | -     |


## Some Timing :

```
In Zig
day01     in   +90 us : part1=70720      part2=207148

In C++
day01_speed_iter        in 37.0242 us : part1=70720     part2=207148

In Rust
day01 in    33.67 us : part1=70720      part2=207148
```