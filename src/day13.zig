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
    const nrun = 1;
    for (0..nrun) |_| {
        var file = try std.fs.cwd().openFile(filename.?, .{ .mode = .read_only });
        defer file.close();

        const read_buf = try file.readToEndAlloc(allocator, 1024 * 1024);
        defer allocator.free(read_buf);
        var it = std.mem.splitAny(u8, read_buf, "\n");

        var acc_part1: u64 = 0;
        var acc_part2: u64 = 0;

        var board = std.ArrayList([]const u8).init(allocator);
        while (it.next()) |line| {
            if (line.len == 0) {
                // the puzzle input should finish with a newline
                for (board.items) |l| {
                    std.debug.print("  {s}\n", .{l});
                }
                std.debug.print("\n", .{});

                const width = board.items[0].len;
                const height = board.items.len;
                // horizontal
                {
                    for (1..height) |row| {
                        const max_spacing = @min(row, height - row);
                        var n_reflection: u64 = 0;
                        var has_jocker = true;
                        for (0..max_spacing) |spacing| {
                            const line1 = board.items[row - spacing - 1];
                            const line2 = board.items[row + spacing];

                            const index_first_diff = std.mem.indexOfDiff(u8, line1, line2);
                            if (index_first_diff == null) {
                                n_reflection += 1;
                            } else if (has_jocker) {
                                std.debug.print("row {d} index first diff : {d}\n", .{ row, index_first_diff.? });
                                const index_second_diff = std.mem.indexOfDiff(u8, line1[index_first_diff.? + 1 ..], line2[index_first_diff.? + 1 ..]);

                                std.debug.print("  line1 sliced {s}\n", .{line1[index_first_diff.? + 1 ..]});
                                std.debug.print("  line2 sliced {s}\n", .{line2[index_first_diff.? + 1 ..]});
                                std.debug.print("row {d} index second diff : {?}\n", .{ row, index_second_diff });
                                if (index_second_diff == null) {
                                    n_reflection += 1;
                                    has_jocker = false;
                                    // TODO: This solution allow a different smudge each time so it doesn't work
                                }
                            }
                        }
                        if (n_reflection == max_spacing) {
                            acc_part1 += 100 * row;
                        }
                        if (n_reflection > 0 and n_reflection == max_spacing) {
                            std.debug.print("n {} max {}\n", .{ n_reflection, max_spacing });
                            std.debug.print("part2 reflection line {}\n", .{row});
                            acc_part2 += 100 * row;
                        }
                    }
                }
                // vertical
                {
                    var transposed = std.ArrayList(u8).init(allocator);
                    try transposed.ensureTotalCapacity(width * height);
                    for (0..width) |x| {
                        for (0..height) |y| {
                            transposed.appendAssumeCapacity(board.items[y][x]);
                        }
                    }
                    // width of the orignal board is the height of the transposed board
                    outer: for (1..width) |row| {
                        const max_spacing = @min(row, width - row);
                        for (0..max_spacing) |spacing| {
                            const offset_line1 = (row - spacing - 1) * height;
                            const offset_line2 = (row + spacing) * height;
                            if (!std.mem.eql(u8, transposed.items[offset_line1 .. offset_line1 + height], transposed.items[offset_line2 .. offset_line2 + height]))
                                break;
                        } else {
                            acc_part1 += row;
                            break :outer;
                        }
                    }
                }
                std.debug.print("end \n", .{});

                board.clearRetainingCapacity();
                continue;
            }
            try board.append(line);
        }
        part1 = acc_part1;
        part2 = acc_part2;
    }
    const tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day13 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
