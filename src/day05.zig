const std = @import("std");

pub const std_options = struct {
    pub const log_level = .info;
};

pub fn sortPair(_: void, a: [2]u64, b: [2]u64) bool {
    return a[0] < b[0];
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

        // parse seed
        var seeds_p1 = std.ArrayList(u64).init(allocator);
        var seeds_p2 = std.ArrayList([2]u64).init(allocator);
        // to avoid processing just transformed range during mapping, I use a mask to mark range already processed
        var seeds_mask_p1 = std.ArrayList(bool).init(allocator);
        var seeds_mask_p2 = std.ArrayList(bool).init(allocator);

        // Parse seeds
        {
            var first_line = it.next().?;
            const column_idx = std.mem.indexOf(u8, first_line, ":");

            var seeds_it = std.mem.tokenizeScalar(u8, first_line[column_idx.? + 1 ..], ' ');
            while (seeds_it.next()) |str| {
                const seed = try std.fmt.parseUnsigned(u32, str, 10);
                try seeds_p1.append(seed);
                try seeds_mask_p1.append(false);
            }
            var seeds_p1_it = std.mem.window(u64, seeds_p1.items, 2, 2);
            while (seeds_p1_it.next()) |range| {
                // we use the parsing of the seed from part1 to create seeds for part2
                try seeds_p2.append([_]u64{ range[0], range[0] + range[1] - 1 });
                try seeds_mask_p2.append(false);
            }
        }

        while (it.next()) |line| {
            if (line.len == 0)
                continue;
            const column_idx = std.mem.indexOf(u8, line, ":");
            if (column_idx != null) {
                // reset mask between mapping group
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
            // method: we propagate each seed
            for (seeds_p1.items, seeds_mask_p1.items) |*seed, *mask| {
                if (!mask.* and seed.* >= ranges[1] and seed.* <= ranges[1] + ranges[2]) {
                    seed.* = seed.* - ranges[1] + ranges[0];
                    mask.* = true;
                }
            }
            // part2
            // method: we propagate directly the range
            // so we should compute intersection between range of seed and range of mapping
            // I made so many mistake on range split so I write each possible case manually
            const rsource_min = ranges[1];
            const rsource_max = ranges[1] + ranges[2] - 1;
            const rdest_min = ranges[0];
            // we don't want pointer to be invalidated during append
            // each range is splitted at most in 3 so we reserve 2 more time the same length
            try seeds_p2.ensureUnusedCapacity(seeds_p2.items.len * 2);
            try seeds_mask_p2.ensureUnusedCapacity(seeds_p2.items.len * 2);
            for (seeds_p2.items, seeds_mask_p2.items) |*seed_range, *mask| {
                // if the seed-range is already processed we skip
                if (mask.*) {
                    continue;
                }
                var s_min = &seed_range[0];
                var s_max = &seed_range[1];

                // seed-range completly outside of mapping-range
                if (s_max.* < rsource_min or s_min.* > rsource_max) {
                    continue;
                }

                // seed-range completly inside of mapping-range
                if (s_min.* >= rsource_min and s_max.* <= rsource_max) {
                    s_min.* = s_min.* - rsource_min + rdest_min;
                    s_max.* = s_max.* - rsource_min + rdest_min;
                    mask.* = true;
                    continue;
                }

                // mapping-range completly inside seed-range
                if (s_min.* <= rsource_min and s_max.* >= rsource_max) {
                    // low part
                    if (s_min.* != rsource_min) {
                        var low_min = s_min.*;
                        var low_max = rsource_min - 1;
                        seeds_p2.appendAssumeCapacity([_]u64{ low_min, low_max });
                        seeds_mask_p2.appendAssumeCapacity(false);
                    }
                    // high part
                    if (s_max.* != rsource_max) {
                        var high_min = rsource_max + 1;
                        var high_max = s_max.*;
                        seeds_p2.appendAssumeCapacity([_]u64{ high_min, high_max });
                        seeds_mask_p2.appendAssumeCapacity(false);
                    }
                    // middle part
                    s_min.* = rdest_min;
                    s_max.* = rdest_min + rsource_max - rsource_min;
                    mask.* = true;
                    continue;
                }

                // mapping-range half high of seed-range
                if (s_min.* < rsource_min and s_max.* <= rsource_max) {
                    // low part
                    var low_min = s_min.*;
                    var low_max = rsource_min - 1;
                    seeds_p2.appendAssumeCapacity([_]u64{ low_min, low_max });
                    seeds_mask_p2.appendAssumeCapacity(false);
                    // middle part
                    s_min.* = rdest_min;
                    s_max.* = rdest_min + s_max.* - rsource_min;
                    mask.* = true;
                    continue;
                }

                // mapping-range half low of seed-range
                if (s_min.* >= rsource_min and s_max.* > rsource_max) {
                    // high part
                    var high_min = rsource_max + 1;
                    var high_max = s_max.*;
                    seeds_p2.appendAssumeCapacity([_]u64{ high_min, high_max });
                    seeds_mask_p2.appendAssumeCapacity(false);
                    // middle part
                    s_min.* = rdest_min + s_min.* - rsource_min;
                    s_max.* = rdest_min + rsource_max - rsource_min;
                    mask.* = true;
                    continue;
                }
            }
        }

        std.sort.pdq(u64, seeds_p1.items, {}, std.sort.asc(u64));
        std.sort.pdq([2]u64, seeds_p2.items, {}, sortPair);

        part1 = seeds_p1.items[0];
        part2 = seeds_p2.items[0][0];
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day05 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
