const std = @import("std");

pub const std_options: std.Options = .{ .log_level = .info };

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

    const filename = args.next();
    if (filename == null) {
        std.log.err("Missing filename", .{});
        return;
    }

    const tic = std.time.microTimestamp();
    var part1: u64 = 0;
    var part2: u64 = 0;
    const nrun = 10000;
    for (0..nrun) |_| {
        var file = try std.fs.cwd().openFile(filename.?, .{ .mode = .read_only });
        defer file.close();

        const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
        defer allocator.free(read_buf);
        var it = std.mem.splitAny(u8, read_buf, "\n");

        const colors_string = [_][]const u8{ "red", "green", "blue" };
        // bag contain only 12 red cubes, 13 green cubes, and 14 blue cubes
        const color_total_cube = [3]i32{ 12, 13, 14 };
        var acc_part1: u64 = 0;
        var acc_part2: u64 = 0;

        // Loop on games
        while (it.next()) |line| {
            if (line.len == 0)
                continue;

            var color_min_cube = [3]i32{ 0, 0, 0 };
            var is_possible_game = true;

            // Get game index
            const column_idx = std.mem.indexOf(u8, line, ":");
            const game_idx = try std.fmt.parseUnsigned(u32, line[5..column_idx.?], 10);

            // Split per color (we don't need to keep draws separated
            var split_color = std.mem.splitAny(u8, line[column_idx.? + 1 ..], ";,");
            while (split_color.next()) |color_sample| {
                for (colors_string, color_total_cube, &color_min_cube) |color_string, total_cube, *min_cube| {
                    const color_idx = std.mem.lastIndexOf(u8, color_sample, color_string);
                    if (color_idx == null)
                        continue;

                    // we have to trim whitespace
                    const num = try std.fmt.parseUnsigned(i32, std.mem.trim(u8, color_sample[0..color_idx.?], " "), 10);
                    // part1
                    if (is_possible_game and num > total_cube) {
                        is_possible_game = false;
                    }
                    // part2
                    if (num > min_cube.*) {
                        min_cube.* = num;
                    }
                }
            }

            if (is_possible_game) {
                acc_part1 += game_idx;
            }
            acc_part2 += @intCast(color_min_cube[0] * color_min_cube[1] * color_min_cube[2]);
        }
        part1 = acc_part1;
        part2 = acc_part2;
    }
    const tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day02 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
