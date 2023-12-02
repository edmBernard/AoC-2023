const std = @import("std");

pub const std_options = struct {
    pub const log_level = .info;
};

fn sum(array: []u32) u64 {
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
    const nrun = 1;
    for (0..nrun) |_| {
        var file = try std.fs.cwd().openFile(filename.?, .{ .mode = .read_only });
        defer file.close();

        var read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
        defer allocator.free(read_buf);
        var it = std.mem.splitAny(u8, read_buf, "\n");

        var impossible_game_idx = std.ArrayList(u32).init(allocator);
        defer impossible_game_idx.deinit();
        var all_game_idx = std.ArrayList(u32).init(allocator);
        defer all_game_idx.deinit();

        const colors_string = [_][]const u8{ "red", "green", "blue" };
        // only 12 red cubes, 13 green cubes, and 14 blue cubes
        const color_total_cube = [3]i32{ 12, 13, 14 };

        while (it.next()) |line| {
            if (line.len == 0)
                continue;
            // part1
            {
                // std.debug.print("line : {s}\n", .{line});
                const column_idx = std.mem.indexOf(u8, line, ":");
                const game_idx = try std.fmt.parseInt(u32, line[5..column_idx.?], 10);
                try all_game_idx.append(game_idx);
                // std.debug.print("IDX : {d}\n", .{game_idx});

                var split_game = std.mem.split(u8, line[column_idx.? + 1 ..], ";");
                outer: while (split_game.next()) |sample| {
                    // std.debug.print(" game : {d}, {d}, {d}\n", .{ color_total_cube[0], color_total_cube[1], color_total_cube[2] });
                    // std.debug.print(" sample : {s}\n", .{sample});

                    var split_color = std.mem.split(u8, sample, ",");
                    while (split_color.next()) |color_sample| {
                        // std.debug.print("  color sample : {s}\n", .{color_sample});
                        for (colors_string, 0..) |color_string, color_pos| {
                            // std.debug.print("  color string : {s} {d}\n", .{ color_string, color_pos });
                            const color_idx = std.mem.lastIndexOf(u8, color_sample, color_string);
                            if (color_idx != null) {
                                // std.debug.print("  string to parse : '{s}'\n", .{color_sample[1 .. color_idx.? - 1]});
                                const num = try std.fmt.parseInt(i32, color_sample[1 .. color_idx.? - 1], 10);
                                if (num > color_total_cube[color_pos]) {
                                    try impossible_game_idx.append(game_idx);
                                    break :outer;
                                }
                            }
                        }
                    }
                }
                // std.debug.print(" game : {d}, {d}, {d}\n", .{ color_total_cube[0], color_total_cube[1], color_total_cube[2] });
            }
        }
        part1 = sum(all_game_idx.items) - sum(impossible_game_idx.items);
        part2 = sum(all_game_idx.items) - sum(impossible_game_idx.items);
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day02 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
