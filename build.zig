const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    // b.setPreferredOptimizeMode(.ReleaseFast);
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseFast });

    var buffer_filename = [_]u8{0} ** 20;
    const days = [_][]const u8{ "day01", "day02", "day03", "day04", "day05", "day06", "day07", "day08", "day11", "day12" };
    for (days) |day| {
        var filename = std.fmt.bufPrint(&buffer_filename, "src/{s}.zig", .{day}) catch continue;
        const exe = b.addExecutable(.{
            .name = day,
            .root_source_file = .{ .path = filename },
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(exe);
    }
}
