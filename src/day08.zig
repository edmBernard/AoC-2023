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
        // Don't seem to work for the moment.
        var step_count_part2: u64 = 0;
        {
            var instruction_index: usize = 0;
            var all_node_are_ending = false;
            while (!all_node_are_ending) {
                // std.debug.print("Nodes : ", .{});
                // for (current_node_part2.items) |node| {
                //     std.debug.print("{s} ", .{node});
                // }
                // std.debug.print("\n", .{});

                all_node_are_ending = true;
                for (current_node_part2.items) |*node| {
                    // std.debug.print("current node {s}\n", .{node.*});
                    node.* = switch (instructions.items[instruction_index]) {
                        InstructionTag.left => graph.get(node.*).?[0],
                        InstructionTag.right => graph.get(node.*).?[1],
                    };
                    all_node_are_ending = all_node_are_ending and node.*[2] == 'Z';
                }
                instruction_index = if (instruction_index == instructions.items.len - 1) 0 else instruction_index + 1;
                step_count_part2 += 1;
                // if (@mod(step_count_part2, 100000) == 0)
                //     std.debug.print("step = {d}\n", .{step_count_part2});
            }
        }
        part1 = step_count_part1;
        part2 = step_count_part2;
    }
    var tac: i64 = std.time.microTimestamp() - tic;
    std.log.info("Zig  day08 in {d:>20.2} us : part1={:<10} part2={:<10}", .{ @as(f32, @floatFromInt(tac)) / @as(f32, nrun), part1, part2 });
}
