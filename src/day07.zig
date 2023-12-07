const std = @import("std");

pub const std_options = struct {
    pub const log_level = .info;
};

const HandType = struct { cards: [5]u8, bid: u64 };

pub fn sortHandsPart1(_: void, a: HandType, b: HandType) bool {
    var cards_hash_a = [_]u8{0} ** 14;
    for (a.cards) |card| {
        cards_hash_a[card] += 1;
    }
    var cards_hash_b = [_]u8{0} ** 14;
    for (b.cards) |card| {
        cards_hash_b[card] += 1;
    }

    std.sort.pdq(u8, &cards_hash_a, {}, std.sort.desc(u8));
    std.sort.pdq(u8, &cards_hash_b, {}, std.sort.desc(u8));
    const order = std.mem.order(u8, &cards_hash_a, &cards_hash_b);
    switch (order) {
        std.math.Order.gt => return false,
        std.math.Order.lt => return true,
        std.math.Order.eq => {
            const second_order = std.mem.order(u8, &a.cards, &b.cards);
            switch (second_order) {
                std.math.Order.gt => return false,
                std.math.Order.lt => return true,
                std.math.Order.eq => unreachable,
            }
        },
    }
    unreachable;
}

pub fn sortHandsPart2(_: void, a: HandType, b: HandType) bool {
    // create an histogram of each hand to compare quantity
    var cards_hash_a = [_]u8{0} ** 14;
    for (a.cards) |card| {
        cards_hash_a[card] += 1;
    }
    var cards_hash_b = [_]u8{0} ** 14;
    for (b.cards) |card| {
        cards_hash_b[card] += 1;
    }
    var number_of_joker_a = cards_hash_a[0];
    var number_of_joker_b = cards_hash_b[0];
    // reset joker to not count them
    cards_hash_a[0] = 0;
    cards_hash_b[0] = 0;

    std.sort.pdq(u8, &cards_hash_a, {}, std.sort.desc(u8));
    std.sort.pdq(u8, &cards_hash_b, {}, std.sort.desc(u8));
    // put joker in the already bigger bin
    cards_hash_a[0] += number_of_joker_a;
    cards_hash_b[0] += number_of_joker_b;

    const order = std.mem.order(u8, &cards_hash_a, &cards_hash_b);
    switch (order) {
        std.math.Order.gt => return false,
        std.math.Order.lt => return true,
        std.math.Order.eq => {
            const second_order = std.mem.order(u8, &a.cards, &b.cards);
            switch (second_order) {
                std.math.Order.gt => return false,
                std.math.Order.lt => return true,
                std.math.Order.eq => unreachable,
            }
        },
    }
    unreachable;
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
        var hands_part1 = std.ArrayList(HandType).init(allocator);
        defer hands_part1.deinit();
        var hands_part2 = std.ArrayList(HandType).init(allocator);
        defer hands_part2.deinit();

        var acc_part1: u64 = 0;
        var acc_part2: u64 = 0;

        while (it.next()) |line| {
            if (line.len == 0)
                continue;

            // parse
            var line_it = std.mem.tokenizeScalar(u8, line, ' ');
            var cards = line_it.next().?;
            var bid = try std.fmt.parseUnsigned(u32, line_it.next().?, 10);
            var cards_int = [_]u8{0} ** 5;
            // part1
            var card_value_part1 = [_]u8{ '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A' };
            for (cards, &cards_int) |card_c, *card_i| {
                card_i.* = @intCast(std.mem.indexOfScalar(u8, &card_value_part1, card_c).?);
            }
            try hands_part1.append(.{ .cards = cards_int, .bid = bid });
            // part2
            var card_value_part2 = [_]u8{ 'J', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'Q', 'K', 'A' };
            for (cards, &cards_int) |card_c, *card_i| {
                card_i.* = @intCast(std.mem.indexOfScalar(u8, &card_value_part2, card_c).?);
            }
            try hands_part2.append(.{ .cards = cards_int, .bid = bid });
        }
        // part1
        std.sort.pdq(HandType, hands_part1.items, {}, sortHandsPart1);
        for (hands_part1.items, 1..) |hand, idx| {
            acc_part1 += hand.bid * idx;
        }
        // part2
        std.sort.pdq(HandType, hands_part2.items, {}, sortHandsPart2);
        for (hands_part2.items, 1..) |hand, idx| {
            acc_part2 += hand.bid * idx;
        }

        part1 = acc_part1;
        part2 = acc_part2;
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day07 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
