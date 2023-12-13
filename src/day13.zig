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
                    outer: for (1..height) |row| {
                        const max_spacing = @min(row, height - row);
                        for (0..max_spacing) |spacing| {
                            if (!std.mem.eql(u8, board.items[row - spacing - 1], board.items[row + spacing]))
                                break;
                        } else {
                            acc_part1 += 100 * row;
                            break :outer;
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
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day13 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
