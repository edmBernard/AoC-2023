const std = @import("std");

pub const std_options = struct {
    pub const log_level = .info;
};

fn sum(array: []u64) u64 {
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

        // number of matching per card
        var scratch_match = std.ArrayList(u64).init(allocator);
        defer scratch_match.deinit();
        // number of repetition of card
        var scratch_rep = std.ArrayList(u64).init(allocator);
        defer scratch_rep.deinit();

        while (it.next()) |line| {
            if (line.len == 0)
                continue;
            // part1
            // Get game index
            const column_idx = std.mem.indexOf(u8, line, ":");
            const game_idx = try std.fmt.parseInt(u32, std.mem.trim(u8, line[5..column_idx.?], " "), 10);
            std.debug.print("Card n: {d}\n", .{game_idx});

            var number_series = std.mem.splitScalar(u8, line[column_idx.? + 1 ..], '|');
            var winning_string = number_series.next().?;
            var yours_string = number_series.next().?;

            var winning_numbers = std.ArrayList(u64).init(allocator);
            defer winning_numbers.deinit();

            var winning_number_it = std.mem.tokenizeScalar(u8, winning_string, ' ');
            while (winning_number_it.next()) |str| {
                const number = try std.fmt.parseInt(u32, str, 10);
                try winning_numbers.append(number);
            }

            var yours_numbers = std.ArrayList(u64).init(allocator);
            defer yours_numbers.deinit();

            var yours_number_it = std.mem.tokenizeScalar(u8, yours_string, ' ');
            while (yours_number_it.next()) |str| {
                const number = try std.fmt.parseInt(u32, str, 10);
                try yours_numbers.append(number);
            }
            var number_match: u64 = 0;
            for (winning_numbers.items) |winning_number| {
                for (yours_numbers.items) |your_number| {
                    if (your_number == winning_number) {
                        number_match += 1;
                    }
                }
            }
            if (number_match > 0) {
                acc_part1 += try std.math.powi(u64, 2, number_match - 1);
                std.debug.print("Card n: {d}, match {d}\n", .{ game_idx, number_match });
            }
            try scratch_match.append(number_match);
            try scratch_rep.append(1);
        }
        for (scratch_match.items, 0..) |match, offset| {
            for (0..match) |idx| {
                scratch_rep.items[offset + idx + 1] += scratch_rep.items[offset];
            }
        }
        for (scratch_rep.items, 0..) |rep, idx| {
            std.debug.print("rep {}, idx:{}\n", .{ rep, idx });
            acc_part2 += rep;
        }
        part1 = acc_part1;
        part2 = acc_part2;
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day04 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
