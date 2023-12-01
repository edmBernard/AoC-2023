const std = @import("std");

pub const std_options = struct {
    pub const log_level = .info;
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

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
    const nrun = 10000;
    for (0..nrun) |_| {
        var file = try std.fs.cwd().openFile(filename.?, .{ .mode = .read_only });
        defer file.close();

        var read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
        defer allocator.free(read_buf);
        var it = std.mem.splitAny(u8, read_buf, "\n");

        var acc_part1: u64 = 0;
        var acc_part2: u64 = 0;

        while (it.next()) |line| {
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
                    acc_part1 += parsedLine.items[0] * 10 + parsedLine.items[parsedLine.items.len - 1];
                }
            }
            // part2
            {
                var digits_string = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };
                var parsedLine = std.ArrayList(u64).init(allocator);
                defer parsedLine.deinit();
                // We use this method because word can overlap like "nineight"
                outer: for (0..line.len) |i| {
                    var slice = line[i..];
                    var digit = slice[0] - '0';
                    if (digit >= 0 and digit < 10) {
                        try parsedLine.append(digit);
                    } else {
                        for (digits_string, 1..) |str, num| {
                            if (std.mem.startsWith(u8, slice, str)) {
                                try parsedLine.append(num);
                                continue :outer;
                            }
                        }
                    }
                }
                if (parsedLine.items.len > 0) {
                    acc_part2 += parsedLine.items[0] * 10 + parsedLine.items[parsedLine.items.len - 1];
                }
            }
        }
        part1 = acc_part1;
        part2 = acc_part2;
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day01 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
