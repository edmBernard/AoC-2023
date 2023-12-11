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
        const Coord = struct { x: i64, y: i64 };

        var galaxy_position = std.ArrayList(Coord).init(allocator);
        defer galaxy_position.deinit();
        var expanded_column = std.ArrayList(bool).init(allocator);
        defer expanded_column.deinit();
        var expanded_row = std.ArrayList(bool).init(allocator);
        defer expanded_row.deinit();
        var image = std.ArrayList(bool).init(allocator);
        defer image.deinit();
        var line_size: usize = 0;
        var row: usize = 0;
        var is_first_line = true;
        while (it.next()) |line| {
            if (line.len == 0)
                continue;
            if (is_first_line) {
                line_size = line.len;
                try expanded_column.appendNTimes(true, line_size);
            }
            var has_galaxy = false;
            for (line, 0..) |c, col| {
                switch (c) {
                    '.' => try image.append(false),
                    '#' => {
                        try image.append(true);
                        try galaxy_position.append(.{ .x = @intCast(col), .y = @intCast(row) });
                        has_galaxy = true;
                        expanded_column.items[col] = false;
                    },
                    else => unreachable,
                }
            }
            try expanded_row.append(!has_galaxy);
            row += 1;
        }

        for (galaxy_position.items, 0..) |galaxy1, idx| {
            for (galaxy_position.items[idx..]) |galaxy2| {
                acc_part1 += std.math.absCast(galaxy1.x - galaxy2.x) + std.math.absCast(galaxy1.y - galaxy2.y);
                acc_part2 += std.math.absCast(galaxy1.x - galaxy2.x) + std.math.absCast(galaxy1.y - galaxy2.y);
                for (@intCast(@min(galaxy1.x, galaxy2.x))..@intCast(@max(galaxy1.x, galaxy2.x))) |x| {
                    if (expanded_column.items[x]) {
                        acc_part1 += 1;
                        acc_part2 += 1000000 - 1;
                    }
                }
                for (@intCast(@min(galaxy1.y, galaxy2.y))..@intCast(@max(galaxy1.y, galaxy2.y))) |y| {
                    if (expanded_row.items[y]) {
                        acc_part1 += 1;
                        acc_part2 += 1000000 - 1;
                    }
                }
            }
        }
        part1 = acc_part1;
        part2 = acc_part2;
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day11 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
