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
        var it = std.mem.splitScalar(u8, read_buf, '\n');

        var acc_part1: u64 = 0;
        var acc_part2: u64 = 0;

        var line_size: ?usize = null;

        // parsed puzzle structure
        const TileTag = enum { number, symbol, nothing };
        const TileType = union(TileTag) { number: u32, symbol: u8, nothing: void };
        var puzzle_input = std.ArrayList(TileType).init(allocator);
        defer puzzle_input.deinit();

        // list of numbers with their index in input_puzzle
        const NumberWithPos = struct {
            number: u32,
            pos: usize,
        };
        var number_list = std.ArrayList(NumberWithPos).init(allocator);
        defer number_list.deinit();
        var increment_number_index = true;
        var number_idx: ?usize = null;

        // list of gear index in input_puzzle
        var gear_list = std.ArrayList(usize).init(allocator);
        defer gear_list.deinit();

        // parse puzzle
        while (it.next()) |line| {
            if (line.len == 0)
                continue;
            line_size = line.len;
            try puzzle_input.ensureUnusedCapacity(line_size.?);

            // create complete number list
            // that allow to replace each digit by it's complete number (ex: the 4 of 467 is replace by 467)
            var it_number = std.mem.tokenizeAny(u8, line, ".*+-$%#&/@=");
            while (it_number.next()) |number_string| {
                const number = try std.fmt.parseInt(u32, number_string, 10);
                try number_list.append(.{ .number = number, .pos = 0 });
            }
            // create input_puzzle
            for (line) |c| {
                if (c == '.') {
                    puzzle_input.appendAssumeCapacity(TileType{ .nothing = {} });
                    increment_number_index = true;
                } else if (std.ascii.isDigit(c)) {
                    if (increment_number_index) {
                        number_idx = if (number_idx == null) 0 else number_idx.? + 1;
                        number_list.items[number_idx.?].pos = puzzle_input.items.len;
                    }
                    puzzle_input.appendAssumeCapacity(TileType{ .number = number_list.items[number_idx.?].number });
                    increment_number_index = false;
                } else {
                    if (c == '*') {
                        try gear_list.append(puzzle_input.items.len);
                    }
                    puzzle_input.appendAssumeCapacity(TileType{ .symbol = c });
                    increment_number_index = true;
                }
            }
        }
        // common const for both part
        const dirx = [_]i32{ 1, 0, -1, -1, -1, 0, 1, 1 };
        const diry = [_]i32{ 1, 1, 1, 0, -1, -1, -1, 0 };
        const width = line_size.?;
        const height = puzzle_input.items.len / line_size.?;

        // part1
        {
            for (number_list.items) |n| {
                acc_part1 += n.number;
                outer: for (0..std.math.log10_int(n.number) + 1) |offset| {
                    var x: i32 = @intCast(@mod(n.pos + offset, width));
                    var y: i32 = @intCast(@divFloor(n.pos, width));

                    for (dirx, diry) |dx, dy| {
                        const new_x: usize = @intCast(std.math.clamp(x + dx, 0, @as(i32, @intCast(width - 1))));
                        const new_y: usize = @intCast(std.math.clamp(y + dy, 0, @as(i32, @intCast(height - 1))));
                        switch (puzzle_input.items[new_x + width * new_y]) {
                            TileTag.symbol => break :outer,
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
                // list of numbers adjacent to the gear
                var nums = std.ArrayList(u32).init(allocator);
                defer nums.deinit();

                var x: i32 = @intCast(@mod(gear_idx, width));
                var y: i32 = @intCast(@divFloor(gear_idx, width));

                dir: for (dirx, diry) |dx, dy| {
                    const new_x: usize = @intCast(std.math.clamp(x + dx, 0, @as(i32, @intCast(width - 1))));
                    const new_y: usize = @intCast(std.math.clamp(y + dy, 0, @as(i32, @intCast(height - 1))));
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
