const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const rlm = b.dependency("Omni_RLM", .{});
    const test_filters = b.option([]const u8, "test-filter", "Comma-separated list of test filters to run");

    const exe = b.addExecutable(.{
        .name = "omniclaw",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "omni-rlm", .module = rlm.module("omni-rlm") },
            },
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    b.step("run", "Run OmniClaw").dependOn(&run_cmd.step);

    const test_comp = b.addTest(.{
        .root_module = b.addModule("test", .{
            .root_source_file = b.path("src/test.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "omni-rlm", .module = rlm.module("omni-rlm") },
            },
        }),
        .filters = &.{test_filters orelse ""},
    });

    const test_artifact = b.addRunArtifact(test_comp);
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&test_artifact.step);
}
