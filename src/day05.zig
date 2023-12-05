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
        var it = std.mem.splitAny(u8, read_buf, "\n");

        // parse seed
        var seeds_p1 = std.ArrayList(u64).init(allocator);
        var seeds_mask_p1 = std.ArrayList(bool).init(allocator);
        var seeds_p2 = std.ArrayList(u64).init(allocator);
        var seeds_mask_p2 = std.ArrayList(bool).init(allocator);
        {
            var first_line = it.next().?;
            const column_idx = std.mem.indexOf(u8, first_line, ":");

            var seeds_it = std.mem.tokenizeScalar(u8, first_line[column_idx.? + 1 ..], ' ');
            while (seeds_it.next()) |str| {
                const seed = try std.fmt.parseUnsigned(u32, str, 10);
                try seeds_p1.append(seed);
                try seeds_mask_p1.append(false);
            }
            // Completly brain dead solution I create as many seed there is.
            // A better solution should probably be to keep them in the form of range and intersect range
            // btw, It seems it don't work
            var seeds_p1_it = std.mem.window(u64, seeds_p1.items, 2, 2);
            while (seeds_p1_it.next()) |range| {
                // we use the parsing of the seed from part1 to create seeds for part2
                for (range[0]..range[0] + range[1] + 1) |seed| {
                    try seeds_p2.append(seed);
                    try seeds_mask_p2.append(false);
                }
            }
        }

        while (it.next()) |line| {
            if (line.len == 0)
                continue;
            const column_idx = std.mem.indexOf(u8, line, ":");
            if (column_idx != null) {
                // reset mask between group
                for (seeds_mask_p1.items) |*mask| {
                    mask.* = false;
                }
                for (seeds_mask_p2.items) |*mask| {
                    mask.* = false;
                }
                continue;
            }
            // create map
            var range_it = std.mem.tokenizeScalar(u8, line, ' ');
            var ranges = [_]usize{0} ** 3;
            var idx: usize = 0; // there is probably a better to do that indexing in the loop
            while (range_it.next()) |str| {
                const value = try std.fmt.parseUnsigned(u32, str, 10);
                ranges[idx] = value;
                idx += 1;
            }

            // part1
            for (seeds_p1.items, seeds_mask_p1.items) |*seed, *mask| {
                if (!mask.* and seed.* >= ranges[1] and seed.* <= ranges[1] + ranges[2]) {
                    seed.* = seed.* - ranges[1] + ranges[0];
                    mask.* = true;
                }
            }
            // part2
            for (seeds_p2.items, seeds_mask_p2.items) |*seed, *mask| {
                if (!mask.* and seed.* >= ranges[1] and seed.* <= ranges[1] + ranges[2]) {
                    seed.* = seed.* - ranges[1] + ranges[0];
                    mask.* = true;
                }
            }
            std.debug.print("interation : {s}\n", .{line});
        }

        std.sort.pdq(u64, seeds_p1.items, {}, std.sort.asc(u64));
        std.sort.pdq(u64, seeds_p2.items, {}, std.sort.asc(u64));

        part1 = seeds_p1.items[0];
        part2 = seeds_p2.items[0];
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day01 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
