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
                var has_digits = false;
                var firstDigit: u32 = 0;
                var lastDigit: u32 = 0;
                for (line) |c| {
                    var digit = c - '0';
                    if (digit >= 0 and digit < 10) {
                        if (!has_digits) {
                            firstDigit = digit;
                            has_digits = true;
                        }
                        lastDigit = digit;
                    }
                }
                if (has_digits) {
                    acc_part1 += firstDigit * 10 + lastDigit;
                }
            }
            // part2
            {
                var digits_string = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };
                var has_digits = false;
                var firstDigit: u64 = 0;
                var lastDigit: u64 = 0;
                // We use this method because word can overlap like "nineight"
                outer: for (0..line.len) |i| {
                    var slice = line[i..];
                    var digit = slice[0] - '0';
                    if (digit >= 0 and digit < 10) {
                        if (!has_digits) {
                            firstDigit = digit;
                            has_digits = true;
                        }
                        lastDigit = digit;
                    } else {
                        for (digits_string, 1..) |str, value| {
                            if (std.mem.startsWith(u8, slice, str)) {
                                if (!has_digits) {
                                    firstDigit = value;
                                    has_digits = true;
                                }
                                lastDigit = value;
                                continue :outer;
                            }
                        }
                    }
                }
                if (has_digits) {
                    acc_part2 += firstDigit * 10 + lastDigit;
                }
            }
        }
        part1 = acc_part1;
        part2 = acc_part2;
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day01 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
