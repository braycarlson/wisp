const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const win32_dep = b.dependency("zigwin32", .{});
    const win32 = win32_dep.module("win32");

    const wisp = b.addModule("wisp", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    wisp.addImport("win32", win32);

    const test_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    test_module.addImport("win32", win32);

    const tests = b.addTest(.{ .root_module = test_module });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run unit tests");

    test_step.dependOn(&run_tests.step);

    const examples_step = b.step("examples", "Build all examples");

    const examples = [_][]const u8{
        "basic",
    };

    for (examples) |name| {
        const path = b.fmt("examples/{s}.zig", .{name});

        const module = b.createModule(.{
            .root_source_file = b.path(path),
            .target = target,
            .optimize = optimize,
        });

        module.addImport("win32", win32);
        module.addImport("wisp", wisp);

        const exe = b.addExecutable(.{ .name = name, .root_module = module });
        exe.subsystem = .Windows;

        const install = b.addInstallArtifact(exe, .{});
        examples_step.dependOn(&install.step);
    }
}
