const std = @import("std");

pub const log_level: std.log.Level = .info;

fn sum(array: []u64) u64 {
    var acc: u64 = 0;
    for (array) |value| {
        acc += value;
    }
    return acc;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    // skip exectutable name
    _ = args.skip();

    var filename = args.next();
    if (filename == null) {
        std.log.err("Missing filename", .{});
        return;
    }

    var tic = std.time.microTimestamp();
    var part1: u64 = 0;
    var part2: u64 = 0;

    for (.{0} ** 1000) |_| {
        var file = try std.fs.cwd().openFile(filename.?, .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();

        var buf: [1024]u8 = undefined;

        var top3Elves: [3]u64 = .{0} ** 3;
        var acc: u64 = 0;
        var list = std.ArrayList(u64).init(allocator);
        defer list.deinit();

        while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            if (line.len == 0) {
                if (acc > top3Elves[0]) {
                    top3Elves[0] = acc;
                    try list.append(acc);
                }
                std.sort.sort(u64, &top3Elves, {}, std.sort.asc(u64));
                acc = 0;
                continue;
            }

            const integer = try std.fmt.parseUnsigned(u64, line, 10);
            acc += integer;
        }
        std.sort.sort(u64, list.items, {}, std.sort.desc(u64));
        part1 = top3Elves[2];
        part2 = sum(&top3Elves);
        part1 = list.items[0];
        part2 = sum(list.items[0..3]);
    }
    var tac = std.time.microTimestamp() - tic;
    std.log.info("day01 \tin {:5} us : part1={:<10} part2={:<10}", .{ @divFloor(tac, 1000), part1, part2 });
}
