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
        var line_it = std.mem.splitAny(u8, read_buf, "\n");

        var acc_part1: i64 = 0;
        var acc_part2: i64 = 0;
        while (line_it.next()) |line| {
            if (line.len == 0)
                continue;

            var serie_part1 = std.ArrayList(i32).init(allocator);
            defer serie_part1.deinit();
            var serie_part2 = std.ArrayList(i32).init(allocator);
            defer serie_part2.deinit();

            var it = std.mem.tokenizeScalar(u8, line, ' ');
            while (it.next()) |number_str| {
                const number = try std.fmt.parseInt(i32, number_str, 10);
                try serie_part1.append(number);
                try serie_part2.append(number);
            }
            // part 1
            {
                var end_index: usize = serie_part1.items.len;
                for (0..serie_part1.items.len) |_| {
                    end_index -= 1;
                    var all_zero = true;
                    for (0..end_index) |idx| {
                        serie_part1.items[idx] = serie_part1.items[idx + 1] - serie_part1.items[idx];
                        if (serie_part1.items[idx] != 0)
                            all_zero = false;
                    }
                    if (all_zero)
                        break;
                }

                for (end_index..serie_part1.items.len) |idx| {
                    acc_part1 += serie_part1.items[idx];
                }
            }
            // part 2
            {
                std.mem.reverse(i32, serie_part2.items);
                var end_index: usize = serie_part2.items.len;
                for (0..serie_part2.items.len) |_| {
                    end_index -= 1;
                    var all_zero = true;
                    for (0..end_index) |idx| {
                        serie_part2.items[idx] = serie_part2.items[idx + 1] - serie_part2.items[idx];
                        if (serie_part2.items[idx] != 0)
                            all_zero = false;
                    }
                    if (all_zero)
                        break;
                }

                for (end_index..serie_part2.items.len) |idx| {
                    acc_part2 += serie_part2.items[idx];
                }
            }
        }
        part1 = @intCast(acc_part1);
        part2 = @intCast(acc_part2);
    }
    const tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day09 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
