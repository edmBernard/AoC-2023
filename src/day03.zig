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
    const nrun = 1;
    for (0..nrun) |_| {
        var file = try std.fs.cwd().openFile(filename.?, .{ .mode = .read_only });
        defer file.close();

        var read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
        defer allocator.free(read_buf);
        var it = std.mem.splitScalar(u8, read_buf, '\n');

        var acc_part1: u64 = 0;
        var acc_part2: u64 = 0;

        const TileTag = enum { number, symbol, nothing };
        const TileType = union(TileTag) { number: u32, symbol: u8, nothing: bool };
        var puzzle_input = std.ArrayList(TileType).init(allocator);
        defer puzzle_input.deinit();
        var all_part_number = std.AutoHashMap(u32, void).init(allocator);
        defer all_part_number.deinit();

        var line_size: ?u64 = null;

        var sum_all_part_number: u64 = 0;
        _ = sum_all_part_number;
        var sum_not_part_number: u64 = 0;
        _ = sum_not_part_number;

        const NumberPos = struct {
            number: u32,
            pos: usize,
        };
        var number_list = std.ArrayList(NumberPos).init(allocator);
        defer number_list.deinit();
        var gear_list = std.ArrayList(usize).init(allocator);
        defer gear_list.deinit();
        var number_idx: i32 = -1;
        var increment_number_index = true;

        while (it.next()) |line| {
            if (line.len == 0)
                continue;
            // parse puzzle

            line_size = line.len;
            var it_number = std.mem.tokenizeAny(u8, line, ".*+-$%#&/@=");
            while (it_number.next()) |number_string| {
                const number = std.fmt.parseInt(u32, number_string, 10) catch continue;
                try number_list.append(.{ .number = number, .pos = 0 });
            }
            std.debug.print("number_list size : {}\n", .{number_list.items.len});
            std.debug.print(" line : {s}\n", .{line});
            for (line) |c| {
                if (c == '.') {
                    try puzzle_input.append(TileType{ .nothing = false });
                    increment_number_index = true;
                } else if (std.ascii.isDigit(c)) {
                    if (increment_number_index) {
                        number_idx += 1;
                        number_list.items[@intCast(number_idx)].pos = puzzle_input.items.len;
                    }
                    try puzzle_input.append(TileType{ .number = number_list.items[@intCast(number_idx)].number });
                    increment_number_index = false;
                } else {
                    if (c == '*') {
                        try gear_list.append(puzzle_input.items.len);
                    }
                    try puzzle_input.append(TileType{ .symbol = c });
                    increment_number_index = true;
                }
            }
        }
        // part1
        {
            const dirx = [_]i32{ 1, 0, -1, -1, -1, 0, 1, 1 };
            const diry = [_]i32{ 1, 1, 1, 0, -1, -1, -1, 0 };
            const width = line_size.?;
            const height = puzzle_input.items.len / line_size.?;

            for (number_list.items) |n| {
                acc_part1 += n.number;
                outer: for (0..std.math.log10_int(n.number) + 1) |offset| {
                    for (dirx, diry) |dx, dy| {
                        var x: i32 = @intCast(@mod(n.pos + offset, width));
                        var y: i32 = @intCast(@divFloor(n.pos, width));
                        const new_x: usize = @intCast(std.math.clamp(x + dx, 0, @as(i32, @intCast(width - 1))));
                        const new_y: usize = @intCast(std.math.clamp(y + dy, 0, @as(i32, @intCast(height - 1))));
                        // std.debug.print("x={} y={}, w={}, h={}\n", .{ x, y, width, height });
                        // std.debug.print("nx={} ny={} i={} s={}\n", .{ new_x, new_y, new_x + width * new_y, puzzle_input.items.len });
                        switch (puzzle_input.items[new_x + width * new_y]) {
                            TileTag.symbol => {
                                // std.debug.print("symbol found\n", .{});
                                break :outer;
                            },
                            TileTag.nothing => continue,
                            TileTag.number => continue,
                        }
                    }
                } else {
                    acc_part1 -= n.number;
                }
            }
        }

        // part2
        {
            for (gear_list.items) |gear_idx| {
                std.debug.print("item = {c}", .{puzzle_input.items[gear_idx].symbol});
            }
            const dirx = [_]i32{ 1, 0, -1, -1, -1, 0, 1, 1 };
            const diry = [_]i32{ 1, 1, 1, 0, -1, -1, -1, 0 };
            const width = line_size.?;
            const height = puzzle_input.items.len / line_size.?;

            for (gear_list.items) |gear_idx| {
                var nums = std.ArrayList(u32).init(allocator);
                defer nums.deinit();

                dir: for (dirx, diry) |dx, dy| {
                    var x: i32 = @intCast(@mod(gear_idx, width));
                    var y: i32 = @intCast(@divFloor(gear_idx, width));
                    const new_x: usize = @intCast(std.math.clamp(x + dx, 0, @as(i32, @intCast(width - 1))));
                    const new_y: usize = @intCast(std.math.clamp(y + dy, 0, @as(i32, @intCast(height - 1))));
                    // std.debug.print("x={} y={}, w={}, h={}\n", .{ x, y, width, height });
                    // std.debug.print("nx={} ny={} i={} s={}\n", .{ new_x, new_y, new_x + width * new_y, puzzle_input.items.len });
                    switch (puzzle_input.items[new_x + width * new_y]) {
                        TileTag.symbol => continue,
                        TileTag.nothing => continue,
                        TileTag.number => |value| {
                            for (nums.items) |num| {
                                if (num == value)
                                    continue :dir;
                            }
                            try nums.append(value);
                        },
                    }
                }
                if (nums.items.len > 1) {
                    acc_part2 += nums.items[0] * nums.items[1];
                }
            }
        }
        part1 = acc_part1;
        part2 = acc_part2;
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day03 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
