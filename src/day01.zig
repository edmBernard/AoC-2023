const std = @import("std");

pub const std_options = struct {
    pub const log_level = .info;
};

fn sum(array: []u64) u64 {
    var acc: u64 = 0;
    for (array) |value| {
        acc += value;
    }
    return acc;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

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
    const nrun = 100;
    for (0..nrun) |_| {
        var file = try std.fs.cwd().openFile(filename.?, .{ .mode = .read_only });
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();

        var buf: [1024]u8 = undefined;

        var acc: u64 = 0;
        _ = acc;
        var digits1 = std.ArrayList(u64).init(allocator);
        defer digits1.deinit();
        var digits2 = std.ArrayList(u64).init(allocator);
        defer digits2.deinit();

        while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            // part1
            {
                var parsedLine = std.ArrayList(u64).init(allocator);
                defer parsedLine.deinit();
                for (line) |c| {
                    var digit = c - '0';
                    if (digit >= 0 and digit < 10) {
                        try parsedLine.append(digit);
                    }
                }
                if (parsedLine.items.len > 0) {
                    try digits1.append(parsedLine.items[0] * 10 + parsedLine.items[parsedLine.items.len - 1]);
                }
            }
            // part2
            {
                var parsedLine = std.ArrayList(u64).init(allocator);
                defer parsedLine.deinit();
                // We use this method because word can overlap like "nineight"
                for (0..line.len) |i| {
                    var slice = line[i..];
                    var digit = slice[0] - '0';
                    if (digit >= 0 and digit < 10) {
                        try parsedLine.append(digit);
                    } else if (std.mem.eql(u8, slice[0..3], "one")) {
                        try parsedLine.append(1);
                    } else if (std.mem.eql(u8, slice[0..3], "two")) {
                        try parsedLine.append(2);
                    } else if (std.mem.eql(u8, slice[0..5], "three")) {
                        try parsedLine.append(3);
                    } else if (std.mem.eql(u8, slice[0..4], "four")) {
                        try parsedLine.append(4);
                    } else if (std.mem.eql(u8, slice[0..4], "five")) {
                        try parsedLine.append(5);
                    } else if (std.mem.eql(u8, slice[0..3], "six")) {
                        try parsedLine.append(6);
                    } else if (std.mem.eql(u8, slice[0..5], "seven")) {
                        try parsedLine.append(7);
                    } else if (std.mem.eql(u8, slice[0..5], "eight")) {
                        try parsedLine.append(8);
                    } else if (std.mem.eql(u8, slice[0..4], "nine")) {
                        try parsedLine.append(9);
                    }
                }
                if (parsedLine.items.len > 0) {
                    try digits2.append(parsedLine.items[0] * 10 + parsedLine.items[parsedLine.items.len - 1]);
                }
            }
        }
        part1 = sum(digits1.items);
        part2 = sum(digits2.items);
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day01 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
