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
    const nrun = 10000;
    for (0..nrun) |_| {
        var file = try std.fs.cwd().openFile(filename.?, .{ .mode = .read_only });
        defer file.close();

        var read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
        defer allocator.free(read_buf);
        var it = std.mem.splitAny(u8, read_buf, "\n");

        var possible_game_idx = std.ArrayList(u32).init(allocator);
        defer possible_game_idx.deinit();

        const colors_string = [_][]const u8{ "red", "green", "blue" };
        // bag content only 12 red cubes, 13 green cubes, and 14 blue cubes
        const color_total_cube = [3]i32{ 12, 13, 14 };
        var acc_part2: u64 = 0;

        // Loop on games
        while (it.next()) |line| {
            if (line.len == 0)
                continue;

            var color_min_cube = [3]i32{ 0, 0, 0 };
            var is_possible_game = true;

            // Get game index
            const column_idx = std.mem.indexOf(u8, line, ":");
            const game_idx = try std.fmt.parseInt(u32, line[5..column_idx.?], 10);

            // Split per draw
            var split_draw = std.mem.split(u8, line[column_idx.? + 1 ..], ";");
            while (split_draw.next()) |draw_sample| {
                // Split per color
                var split_color = std.mem.split(u8, draw_sample, ",");
                while (split_color.next()) |color_sample| {
                    for (colors_string, 0..) |color_string, color_pos| {
                        const color_idx = std.mem.lastIndexOf(u8, color_sample, color_string);
                        if (color_idx != null) {
                            // we have to trim whitespace
                            const num = try std.fmt.parseInt(i32, color_sample[1 .. color_idx.? - 1], 10);
                            // part1
                            if (is_possible_game and num > color_total_cube[color_pos]) {
                                is_possible_game = false;
                            }
                            // part2
                            if (num > color_min_cube[color_pos]) {
                                color_min_cube[color_pos] = num;
                            }
                        }
                    }
                }
            }
            if (is_possible_game) {
                try possible_game_idx.append(game_idx);
            }
            acc_part2 += @intCast(color_min_cube[0] * color_min_cube[1] * color_min_cube[2]);
        }
        part1 = sum(possible_game_idx.items);
        part2 = acc_part2;
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day02 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
