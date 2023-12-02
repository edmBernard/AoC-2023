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

    const exeDay01 = b.addExecutable(.{
        .name = "day01",
        .root_source_file = .{ .path = "src/day01.zig" },
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exeDay01);

    const exeDay02 = b.addExecutable(.{
        .name = "day02",
        .root_source_file = .{ .path = "src/day02.zig" },
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exeDay02);

    const exeDay03 = b.addExecutable(.{
        .name = "day03",
        .root_source_file = .{ .path = "src/day03.zig" },
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exeDay03);
}
