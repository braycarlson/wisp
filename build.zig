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

    const fuzz_module = b.createModule(.{
        .root_source_file = b.path("src/testing/fuzz/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    fuzz_module.addImport("win32", win32);
    fuzz_module.addImport("wisp", wisp);

    const test_step = b.step("test", "Run unit tests");

    const unit_test_module = b.createModule(.{
        .root_source_file = b.path("src/testing/unit/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    unit_test_module.addImport("win32", win32);
    unit_test_module.addImport("wisp", wisp);

    const unit_tests = b.addTest(.{ .root_module = unit_test_module });
    const run_unit_tests = b.addRunArtifact(unit_tests);

    test_step.dependOn(&run_unit_tests.step);

    const fuzz_step = b.step("fuzz", "Run the fuzzer");

    const fuzz_runner_module = b.createModule(.{
        .root_source_file = b.path("src/testing/fuzz/runner.zig"),
        .target = target,
        .optimize = optimize,
    });

    fuzz_runner_module.addImport("win32", win32);
    fuzz_runner_module.addImport("wisp", wisp);

    const fuzzer_exe = b.addExecutable(.{ .name = "fuzzer", .root_module = fuzz_runner_module });
    b.installArtifact(fuzzer_exe);

    const run_fuzzer = b.addRunArtifact(fuzzer_exe);
    if (b.args) |args| run_fuzzer.addArgs(args);
    fuzz_step.dependOn(&run_fuzzer.step);

    const fuzz_test_step = b.step("fuzz-test", "Run fuzz unit tests");

    const fuzz_tests = b.addTest(.{ .root_module = fuzz_module });
    const run_fuzz_tests = b.addRunArtifact(fuzz_tests);

    fuzz_test_step.dependOn(&run_fuzz_tests.step);

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
