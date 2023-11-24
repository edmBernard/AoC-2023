const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    b.setPreferredReleaseMode(.ReleaseFast);
    const mode = b.standardReleaseOptions();

    const exe1 = b.addExecutable("day01", "src/day01.zig");
    exe1.setTarget(target);
    exe1.setBuildMode(mode);
    exe1.install();

    const exe2 = b.addExecutable("day02", "src/day02.zig");
    exe2.setTarget(target);
    exe2.setBuildMode(mode);
    exe2.install();
}
