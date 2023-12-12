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

fn arrangement_count(cache: []?u64, p: usize, g: usize, springs: []const u8, groups: []const u32) u64 {
    // adapted solution from https://github.com/vanam/CodeUnveiled/blob/master/Advent%20Of%20Code%202023/12/main.py
    // no more groups
    if (g >= groups.len) {
        if ((p < springs.len) and std.mem.containsAtLeast(u8, springs[p..], 1, "#")) {
            // eg: .##?????#.. 4,1
            return 0; // not a solution - there are still damaged springs in the record
        }
        return 1;
    }

    if (p >= springs.len) {
        return 0; // we ran out of springs but there are still groups to arrange
    }

    // for above condition it's faster to recompute them than to access cache
    const cache_idx = p * groups.len + g;
    if (cache[cache_idx] != null) {
        return cache[cache_idx].?;
    }

    // use a temp variable to be able to memoize the result
    var res: u64 = 0;

    // damaged group size
    const gs = groups[g];
    if (p + gs >= springs.len) {
        // not enough spings to fill the group
        res = 0;
    } else {
        switch (springs[p]) {
            '?' => {
                // if we can start group of damaged springs here
                // eg: '??#...... 3' we can place 3 '#' and there is '?' or '.' after the group
                // eg: '??##...... 3' we cannot place 3 '#' here
                if (!std.mem.containsAtLeast(u8, springs[p .. p + gs], 1, ".") and springs[p + gs] != '#') {
                    // start damaged group here + this spring is operational ('.')
                    res = arrangement_count(cache, p + gs + 1, g + 1, springs, groups) + arrangement_count(cache, p + 1, g, springs, groups);
                } else {
                    // this spring is operational ('.')
                    res = arrangement_count(cache, p + 1, g, springs, groups);
                }
            },
            '#' => {
                // if we can start damaged group here
                if (!std.mem.containsAtLeast(u8, springs[p .. p + gs], 1, ".") and springs[p + gs] != '#') {
                    res = arrangement_count(cache, p + gs + 1, g + 1, springs, groups);
                } else {
                    // not a solution - we must always start damaged group here
                    res = 0;
                }
            },
            '.' => {
                // operational spring -> go to the next spring
                res = arrangement_count(cache, p + 1, g, springs, groups);
            },
            else => unreachable,
        }
    }
    cache[cache_idx] = res;
    return res;
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
    const nrun = 1000;
    for (0..nrun) |_| {
        var file = try std.fs.cwd().openFile(filename.?, .{ .mode = .read_only });
        defer file.close();

        var read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
        defer allocator.free(read_buf);
        var it = std.mem.splitAny(u8, read_buf, "\n");

        var acc_part1: u64 = 0;
        var acc_part2: u64 = 0;

        while (it.next()) |line| {
            if (line.len == 0)
                continue;

            var groups = std.ArrayList(u32).init(allocator);

            var line_it = std.mem.tokenizeAny(u8, line, " ,");
            var springs_str = line_it.next().?;

            while (line_it.next()) |number| {
                const value = try std.fmt.parseUnsigned(u32, number, 10);
                try groups.append(value);
            }
            // part 1
            {
                var spring_str_expanded = std.ArrayList(u8).init(allocator);
                var group_expanded = std.ArrayList(u32).init(allocator);
                for (0..1) |_| {
                    try spring_str_expanded.appendSlice(springs_str);
                    try spring_str_expanded.append('?');
                    try group_expanded.appendSlice(groups.items);
                }
                var cache = std.ArrayList(?u64).init(allocator);
                try cache.appendNTimes(null, group_expanded.items.len * spring_str_expanded.items.len);
                acc_part1 += arrangement_count(cache.items, 0, 0, spring_str_expanded.items, group_expanded.items);
            }
            // part 2
            {
                var spring_str_expanded = std.ArrayList(u8).init(allocator);
                var group_expanded = std.ArrayList(u32).init(allocator);
                for (0..5) |_| {
                    try spring_str_expanded.appendSlice(springs_str);
                    try spring_str_expanded.append('?');
                    try group_expanded.appendSlice(groups.items);
                }
                var cache = std.ArrayList(?u64).init(allocator);
                try cache.appendNTimes(null, group_expanded.items.len * spring_str_expanded.items.len);
                acc_part2 += arrangement_count(cache.items, 0, 0, spring_str_expanded.items, group_expanded.items);
            }
        }
        part1 = acc_part1;
        part2 = acc_part2;
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day13 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
