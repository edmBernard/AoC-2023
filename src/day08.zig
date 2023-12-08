const std = @import("std");

pub const std_options = struct {
    pub const log_level = .info;
};

fn gcd(comptime T: type, a: T, b: T) T {
    var na = a;
    var nb = b;
    while (nb != 0) {
        var temp = na;
        na = nb;
        nb = @mod(temp, nb);
    }
    return na;
}

fn lcm(comptime T: type, a: T, b: T) T {
    var c = gcd(T, a, b);
    return if (c == 0) 0 else a / c * b;
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
        var line_it = std.mem.splitAny(u8, read_buf, "\n");

        // Parse instruction
        const InstructionTag = enum { left, right };
        var instructions = std.ArrayList(InstructionTag).init(allocator);
        defer instructions.deinit();
        {
            var first_line = line_it.next().?;
            try instructions.ensureUnusedCapacity(first_line.len);
            for (first_line) |c| {
                switch (c) {
                    'R' => instructions.appendAssumeCapacity(InstructionTag.right),
                    'L' => instructions.appendAssumeCapacity(InstructionTag.left),
                    else => unreachable,
                }
            }
        }

        // parse node
        var current_node_part2 = std.ArrayList([]const u8).init(allocator);
        var graph = std.StringHashMap([2][]const u8).init(allocator);
        defer graph.deinit();

        while (line_it.next()) |line| {
            if (line.len == 0)
                continue;

            var it = std.mem.tokenizeAny(u8, line, " =(,)");
            var node_name = it.next().?;

            var left_name = it.next().?;
            var right_name = it.next().?;
            try graph.put(node_name, .{ left_name, right_name });

            if (node_name[2] == 'A')
                try current_node_part2.append(node_name);
        }

        // part 1
        var step_count_part1: u64 = 0;
        {
            var instruction_index: usize = 0;
            var current_node: []const u8 = "AAA";
            while (!std.mem.eql(u8, current_node, "ZZZ")) {
                current_node = switch (instructions.items[instruction_index]) {
                    InstructionTag.left => graph.get(current_node).?[0],
                    InstructionTag.right => graph.get(current_node).?[1],
                };
                instruction_index = if (instruction_index == instructions.items.len - 1) 0 else instruction_index + 1;
                step_count_part1 += 1;
            }
        }
        // part 2
        var result_part2: u64 = 1;
        {
            // the input puzzle have the properties :
            //  - cycle are independent (one input node match exactly one output node
            //  - the cycle have the same length than the distance from start to end
            // the solution is the least common multiple between cycle length

            var cycles_length = std.ArrayList(u64).init(allocator);
            for (current_node_part2.items) |node| {

                // Go to end node
                var current_node = node;
                var offset: u64 = 0;
                var instruction_index: usize = 0;
                while (current_node[2] != 'Z') {
                    current_node = switch (instructions.items[instruction_index]) {
                        InstructionTag.left => graph.get(current_node).?[0],
                        InstructionTag.right => graph.get(current_node).?[1],
                    };
                    instruction_index = if (instruction_index == instructions.items.len - 1) 0 else instruction_index + 1;
                    offset += 1;
                }
                var instruction_index_loop = instruction_index;
                // Compute the cycle length
                var cycle_len: u64 = 0;
                while (true) {
                    current_node = switch (instructions.items[instruction_index]) {
                        InstructionTag.left => graph.get(current_node).?[0],
                        InstructionTag.right => graph.get(current_node).?[1],
                    };
                    instruction_index = if (instruction_index == instructions.items.len - 1) 0 else instruction_index + 1;
                    cycle_len += 1;
                    if (current_node[2] == 'Z' and instruction_index == instruction_index_loop) break;
                }
                if (cycle_len != offset) {
                    std.log.err("Cycle don't have correct property for my solution", .{});
                }
                try cycles_length.append(cycle_len);
            }
            // Compute LCM
            for (cycles_length.items) |elem| {
                result_part2 = lcm(u64, result_part2, elem);
            }
        }
        part1 = step_count_part1;
        part2 = result_part2;
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day08 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
