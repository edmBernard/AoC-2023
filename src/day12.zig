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

        var acc_part1: u64 = 0;
        var acc_part2: u64 = 0;

        while (it.next()) |line| {
            if (line.len == 0)
                continue;

            var spring_damaged = std.ArrayList(bool).init(allocator);
            var spring_mask = std.ArrayList(bool).init(allocator);
            var spring_mask_usize: usize = 0;
            var spring_damaged_usize: usize = 0;

            var check_sum = std.ArrayList(u32).init(allocator);
            defer check_sum.deinit();

            var line_it = std.mem.tokenizeAny(u8, line, " ,");
            var springs_str = line_it.next().?;
            for (springs_str) |spring| {
                spring_mask_usize <<= 1;
                spring_damaged_usize <<= 1;

                switch (spring) {
                    '?' => {
                        spring_mask_usize += 1;
                        try spring_mask.append(false);
                    },
                    else => try spring_mask.append(true),
                }
                switch (spring) {
                    '#' => {
                        spring_damaged_usize += 1;
                        try spring_damaged.append(true);
                    },
                    else => try spring_damaged.append(false),
                }
            }
            while (line_it.next()) |number| {
                const value = try std.fmt.parseUnsigned(u32, number, 10);
                try check_sum.append(value);
            }
            var number_spring = sum(check_sum.items);
            // std.debug.print("unknown = {b:0>10}\n", .{spring_mask_usize});
            // std.debug.print("damaged = {b:0>10}\n", .{spring_damaged_usize});
            var buffer: [64]u8 = [_]u8{0} ** 64;
            for (0..try std.math.powi(u64, 2, springs_str.len)) |value| {
                if (@popCount(value) != number_spring)
                    continue;
                if (value & ~spring_mask_usize != spring_damaged_usize)
                    continue;
                // really really ugly
                var string_repr = try std.fmt.bufPrint(&buffer, "{b}", .{value});
                // std.debug.print("match     = {b:0>10}\n", .{value});
                // std.debug.print("match str = {s}\n", .{string_repr});
                var group_it = std.mem.tokenizeScalar(u8, string_repr, '0');
                for (check_sum.items) |check| {
                    const group = group_it.next().?;
                    if (check != group.len)
                        break;
                } else {
                    acc_part1 += 1;
                }
            }
            // std.debug.print("spring = {any}\n", .{spring_mask.items});
            // std.debug.print("check = {d}\n", .{check_sum.items});
        }
        part1 = acc_part1;
        part2 = acc_part2;
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day12 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
