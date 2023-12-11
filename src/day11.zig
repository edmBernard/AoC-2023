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

        var galaxy_position_part1 = std.ArrayList(Coord).init(allocator);
        defer galaxy_position_part1.deinit();
        var galaxy_position_part2 = std.ArrayList(Coord).init(allocator);
        defer galaxy_position_part2.deinit();
        var expanded_column = std.ArrayList(bool).init(allocator);
        defer expanded_column.deinit();
        var expanded_row = std.ArrayList(bool).init(allocator);
        defer expanded_row.deinit();
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
                if (c == '#') {
                    try galaxy_position_part1.append(.{ .x = @intCast(col), .y = @intCast(row) });
                    has_galaxy = true;
                    expanded_column.items[col] = false;
                }
            }
            try expanded_row.append(!has_galaxy);
            row += 1;
        }
        galaxy_position_part2 = try galaxy_position_part1.clone();

        // compute a lut to convert coord from not-expanded to expanded
        // the speed-up of using of a precomputed lut is around 10%
        var lutx_part1 = try std.ArrayList(i64).initCapacity(allocator, expanded_column.items.len);
        var lutx_part2 = try std.ArrayList(i64).initCapacity(allocator, expanded_column.items.len);
        {
            var accumulator_part1: i64 = 0;
            var accumulator_part2: i64 = 0;
            for (0..expanded_column.items.len) |idx| {
                if (expanded_column.items[idx]) {
                    accumulator_part1 += 2 - 1;
                    accumulator_part2 += 1000000 - 1;
                }
                lutx_part1.appendAssumeCapacity(@as(i64, @intCast(idx)) + accumulator_part1);
                lutx_part2.appendAssumeCapacity(@as(i64, @intCast(idx)) + accumulator_part2);
            }
        }
        var luty_part1 = try std.ArrayList(i64).initCapacity(allocator, expanded_row.items.len);
        var luty_part2 = try std.ArrayList(i64).initCapacity(allocator, expanded_row.items.len);
        {
            var accumulator_part1: i64 = 0;
            var accumulator_part2: i64 = 0;
            for (0..expanded_row.items.len) |idx| {
                if (expanded_row.items[idx]) {
                    accumulator_part1 += 2 - 1;
                    accumulator_part2 += 1000000 - 1;
                }
                luty_part1.appendAssumeCapacity(@as(i64, @intCast(idx)) + accumulator_part1);
                luty_part2.appendAssumeCapacity(@as(i64, @intCast(idx)) + accumulator_part2);
            }
        }

        // part1
        for (galaxy_position_part1.items) |*galaxy| {
            galaxy.x = lutx_part1.items[@intCast(galaxy.x)];
            galaxy.y = luty_part1.items[@intCast(galaxy.y)];
        }
        for (galaxy_position_part1.items, 0..) |galaxy1, idx| {
            for (galaxy_position_part1.items[idx + 1 ..]) |galaxy2| {
                acc_part1 += std.math.absCast(galaxy1.x - galaxy2.x) + std.math.absCast(galaxy1.y - galaxy2.y);
            }
        }
        // part2
        for (galaxy_position_part2.items) |*galaxy| {
            galaxy.x = lutx_part2.items[@intCast(galaxy.x)];
            galaxy.y = luty_part2.items[@intCast(galaxy.y)];
        }
        for (galaxy_position_part2.items, 0..) |galaxy1, idx| {
            for (galaxy_position_part2.items[idx + 1 ..]) |galaxy2| {
                acc_part2 += std.math.absCast(galaxy1.x - galaxy2.x) + std.math.absCast(galaxy1.y - galaxy2.y);
            }
        }

        part1 = acc_part1;
        part2 = acc_part2;
    }

    var tac = std.time.microTimestamp() - tic;
    std.log.info("Zig  day11 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
