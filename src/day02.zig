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

        var acc: u64 = 0;
        var input_puzzle = std.ArrayList(u64).init(allocator);
        defer input_puzzle.deinit();

        while (it.next()) |line| {
            if (line.len == 0) {
                try input_puzzle.append(acc);
                acc = 0;
                continue;
            }

            const integer = try std.fmt.parseUnsigned(u64, line, 10);
            acc += integer;
        }
        std.sort.pdq(u64, input_puzzle.items, {}, std.sort.desc(u64));
        part1 = input_puzzle.items[0];
        part2 = sum(input_puzzle.items[0..3]);
    }
    var tac = std.time.microTimestamp() - tic;
    std.log.info("Zig  day02 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
