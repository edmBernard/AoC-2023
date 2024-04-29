const std = @import("std");

pub const std_options: std.Options = .{ .log_level = .info };

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

        var acc_part1: u64 = 1;
        var acc_part2: u64 = 0;

        // Parse time
        var times = std.ArrayList(u64).init(allocator);
        var total_time_part2: u64 = 0;
        defer times.deinit();
        {
            var first_line = it.next().?;
            const column_idx = std.mem.indexOf(u8, first_line, ":");

            var times_it = std.mem.tokenizeScalar(u8, first_line[column_idx.? + 1 ..], ' ');
            while (times_it.next()) |str| {
                const time = try std.fmt.parseUnsigned(u32, str, 10);
                try times.append(time);
                total_time_part2 = time + total_time_part2 * try std.math.powi(u64, 10, str.len);
            }
        }
        // Parse distance
        var distances = std.ArrayList(u64).init(allocator);
        var total_distance_part2: u64 = 0;
        defer distances.deinit();
        {
            var second_line = it.next().?;
            const column_idx = std.mem.indexOf(u8, second_line, ":");

            var distances_it = std.mem.tokenizeScalar(u8, second_line[column_idx.? + 1 ..], ' ');
            while (distances_it.next()) |str| {
                const distance = try std.fmt.parseUnsigned(u32, str, 10);
                try distances.append(distance);
                total_distance_part2 = distance + total_distance_part2 * try std.math.powi(u64, 10, str.len);
            }
        }

        // part1
        for (distances.items, times.items) |record_distance, total_time| {
            var number_of_way: u64 = 0;
            for (0..total_time) |t| {
                const distance = (total_time - t) * t;
                if (distance > record_distance)
                    number_of_way += 1;
            }
            acc_part1 *= number_of_way;
        }
        // part2
        {
            // Solve the quadratic equation
            const delta: f64 = @floatFromInt(total_time_part2 * total_time_part2 - 4 * total_distance_part2);
            const x1: u64 = @intFromFloat(@floor((@as(f64, @floatFromInt(total_distance_part2)) - std.math.sqrt(delta)) / 2));
            const x2: u64 = @intFromFloat(@floor((@as(f64, @floatFromInt(total_distance_part2)) + std.math.sqrt(delta)) / 2));
            acc_part2 = x2 - x1;
        }
        part1 = acc_part1;
        part2 = acc_part2;
    }
    const tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day06 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
