const std = @import("std");

const wisp = @import("wisp");
const runtime = wisp.runtime;

const Lifecycle = runtime.Lifecycle;
const Stage = runtime.Stage;

const common = @import("common.zig");

pub const stage_count: u8 = 5;
pub const iteration_max: u32 = 0xFFFFFFFF;

pub fn fuzz_lifecycle(random: *std.Random, iterations: u32) !void {
    std.debug.assert(@intFromPtr(random) != 0);
    std.debug.assert(iterations > 0);
    std.debug.assert(iterations <= iteration_max);

    var lifecycle = Lifecycle.init();
    var i: u32 = 0;

    while (i < iterations and i < iteration_max) : (i += 1) {
        std.debug.assert(i < iterations);

        const target = random_stage(random);
        const before = lifecycle.stage;
        const can_transition = before.can_transition_to(target);
        const result = lifecycle.transition(target);

        std.debug.assert(result == can_transition);

        if (result) {
            std.debug.assert(lifecycle.stage == target);
        } else {
            std.debug.assert(lifecycle.stage == before);
        }
    }

    std.debug.assert(i == iterations or i == iteration_max);
}

pub fn fuzz_transitions(seed: u64, iterations: u32) !void {
    std.debug.assert(iterations > 0);
    std.debug.assert(iterations <= iteration_max);

    var prng = std.Random.DefaultPrng.init(seed);
    var random = prng.random();
    var i: u32 = 0;

    while (i < iterations and i < iteration_max) : (i += 1) {
        std.debug.assert(i < iterations);

        var lifecycle = Lifecycle.init();

        std.debug.assert(lifecycle.stage == .created);

        const sequence_len = random.intRangeAtMost(u8, 1, 20);
        var j: u8 = 0;

        while (j < sequence_len) : (j += 1) {
            std.debug.assert(j < sequence_len);

            const target = random_stage(&random);

            _ = lifecycle.transition(target);

            std.debug.assert(@intFromEnum(lifecycle.stage) <= 4);
        }

        std.debug.assert(j == sequence_len);
    }

    std.debug.assert(i == iterations or i == iteration_max);
}

pub fn fuzz_valid_path(random: *std.Random, iterations: u32) !void {
    std.debug.assert(@intFromPtr(random) != 0);
    std.debug.assert(iterations > 0);

    var i: u32 = 0;

    while (i < iterations and i < iteration_max) : (i += 1) {
        std.debug.assert(i < iterations);

        var lifecycle = Lifecycle.init();

        std.debug.assert(lifecycle.stage == .created);

        const valid_paths = [_][]const Stage{
            &[_]Stage{ .configured, .running, .stopping, .stopped },
            &[_]Stage{ .configured, .running, .stopping },
            &[_]Stage{ .configured, .running },
            &[_]Stage{.configured},
        };

        const path_idx = random.intRangeLessThan(usize, 0, valid_paths.len);
        const path = valid_paths[path_idx];

        for (path) |target| {
            const result = lifecycle.transition(target);

            std.debug.assert(result == true);
            std.debug.assert(lifecycle.stage == target);
        }
    }

    std.debug.assert(i == iterations or i == iteration_max);
}

pub fn fuzz_stage_queries(random: *std.Random, iterations: u32) !void {
    std.debug.assert(@intFromPtr(random) != 0);
    std.debug.assert(iterations > 0);

    var i: u32 = 0;

    while (i < iterations and i < iteration_max) : (i += 1) {
        std.debug.assert(i < iterations);

        var lifecycle = Lifecycle.init();

        const target = random_stage(random);

        _ = lifecycle.transition(target);

        const is_configured = lifecycle.is_configured();
        const is_running = lifecycle.is_running();
        const is_stopped = lifecycle.is_stopped();

        const stage_value = @intFromEnum(lifecycle.stage);

        std.debug.assert(stage_value <= 4);

        if (lifecycle.stage == .configured) {
            std.debug.assert(is_configured);
        }

        if (lifecycle.stage == .running) {
            std.debug.assert(is_running);
        }

        if (lifecycle.stage == .stopped) {
            std.debug.assert(is_stopped);
        }
    }

    std.debug.assert(i == iterations or i == iteration_max);
}

fn random_stage(random: *std.Random) Stage {
    std.debug.assert(@intFromPtr(random) != 0);

    const result = common.random_enum(Stage, random);

    return result;
}

const testing = std.testing;

test "fuzz_lifecycle basic" {
    var prng = std.Random.DefaultPrng.init(42);
    var random = prng.random();

    try fuzz_lifecycle(&random, 100);
}

test "fuzz_lifecycle determinism" {
    var prng1 = std.Random.DefaultPrng.init(12345);
    var prng2 = std.Random.DefaultPrng.init(12345);
    var random1 = prng1.random();
    var random2 = prng2.random();

    try fuzz_lifecycle(&random1, 100);
    try fuzz_lifecycle(&random2, 100);
}

test "fuzz_transitions basic" {
    try fuzz_transitions(42, 100);
}

test "fuzz_transitions determinism" {
    try fuzz_transitions(12345, 100);
    try fuzz_transitions(12345, 100);
}

test "fuzz_valid_path basic" {
    var prng = std.Random.DefaultPrng.init(42);
    var random = prng.random();

    try fuzz_valid_path(&random, 50);
}

test "fuzz_stage_queries basic" {
    var prng = std.Random.DefaultPrng.init(42);
    var random = prng.random();

    try fuzz_stage_queries(&random, 100);
}

test "random_stage produces valid stages" {
    var prng = std.Random.DefaultPrng.init(42);
    var random = prng.random();
    var i: u32 = 0;

    while (i < 100) : (i += 1) {
        std.debug.assert(i < 100);

        const stage = random_stage(&random);

        std.debug.assert(@intFromEnum(stage) <= 4);
    }

    std.debug.assert(i == 100);
}

test "Stage transition validity" {
    const created = Stage.created;

    std.debug.assert(created.can_transition_to(.configured) == true);
    std.debug.assert(created.can_transition_to(.running) == false);
    std.debug.assert(created.can_transition_to(.stopped) == false);
    std.debug.assert(created.can_transition_to(.stopping) == false);
}
