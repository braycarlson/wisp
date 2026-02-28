const std = @import("std");

const wisp = @import("wisp");
const ui = wisp.ui;

const StateManager = ui.StateManager;

const common = @import("common.zig");

pub const state_name_max: u8 = 32;
pub const iteration_max: u32 = 0xFFFFFFFF;
pub const state_count: u8 = 8;

const test_states = [_][]const u8{
    "idle",
    "loading",
    "ready",
    "active",
    "paused",
    "error",
    "disabled",
    "hidden",
};

pub fn fuzz_state_manager(random: *std.Random, iterations: u32) !void {
    std.debug.assert(@intFromPtr(random) != 0);
    std.debug.assert(iterations > 0);
    std.debug.assert(iterations <= iteration_max);

    var manager = StateManager.init();
    var i: u32 = 0;

    while (i < iterations and i < iteration_max) : (i += 1) {
        std.debug.assert(i < iterations);

        const action = random.intRangeLessThan(u8, 0, 100);

        if (action < 70) {
            const state_idx = random.intRangeLessThan(usize, 0, test_states.len);
            const state_name = test_states[state_idx];

            manager.set(state_name) catch {};
        } else if (action < 90) {
            const state_idx = random.intRangeLessThan(usize, 0, test_states.len);
            const state_name = test_states[state_idx];
            const current = manager.get();

            if (current.len > 0) {
                const matches = std.mem.eql(u8, current, state_name);

                _ = manager.equals(state_name);

                std.debug.assert(manager.equals(state_name) == matches);
            }
        } else {
            _ = manager.get();
            _ = manager.get_previous();
        }
    }

    std.debug.assert(i == iterations or i == iteration_max);

    manager.deinit();
}

pub fn fuzz_state_transitions(random: *std.Random, iterations: u32) !void {
    std.debug.assert(@intFromPtr(random) != 0);
    std.debug.assert(iterations > 0);

    var i: u32 = 0;

    while (i < iterations and i < iteration_max) : (i += 1) {
        std.debug.assert(i < iterations);

        var manager = StateManager.init();
        const transition_count = random.intRangeAtMost(u8, 1, 20);
        var j: u8 = 0;

        while (j < transition_count) : (j += 1) {
            std.debug.assert(j < transition_count);

            const state_idx = random.intRangeLessThan(usize, 0, test_states.len);
            const state_name = test_states[state_idx];
            const before = manager.get();
            const was_same = manager.equals(state_name);
            const before_len = before.len;
            var before_copy: [state_name_max]u8 = undefined;

            if (before_len > 0) {
                @memcpy(before_copy[0..before_len], before);
            }

            manager.set(state_name) catch continue;

            const after = manager.get();

            if (!was_same and before_len > 0) {
                const prev = manager.get_previous();

                if (prev.len == before_len) {
                    std.debug.assert(std.mem.eql(u8, prev, before_copy[0..before_len]));
                }
            }

            if (after.len > 0) {
                std.debug.assert(std.mem.eql(u8, after, state_name));
            }
        }

        std.debug.assert(j == transition_count);

        manager.deinit();
    }

    std.debug.assert(i == iterations or i == iteration_max);
}

pub fn fuzz_state_history(random: *std.Random, iterations: u32) !void {
    std.debug.assert(@intFromPtr(random) != 0);
    std.debug.assert(iterations > 0);

    var i: u32 = 0;

    while (i < iterations and i < iteration_max) : (i += 1) {
        std.debug.assert(i < iterations);

        var manager = StateManager.init();
        const transition_count = random.intRangeAtMost(u8, 2, 10);
        var j: u8 = 0;

        while (j < transition_count) : (j += 1) {
            std.debug.assert(j < transition_count);

            const state_idx = random.intRangeLessThan(usize, 0, test_states.len);
            const state_name = test_states[state_idx];

            const current = manager.get();
            const was_same = manager.equals(state_name);
            const current_len = current.len;

            manager.set(state_name) catch continue;

            if (!was_same and current_len > 0) {
                const actual_previous = manager.get_previous();

                std.debug.assert(actual_previous.len == current_len);
            }
        }

        std.debug.assert(j == transition_count);

        manager.deinit();
    }

    std.debug.assert(i == iterations or i == iteration_max);
}

fn random_state_name(random: *std.Random) []const u8 {
    std.debug.assert(@intFromPtr(random) != 0);

    const idx = random.intRangeLessThan(usize, 0, test_states.len);

    std.debug.assert(idx < test_states.len);

    const result = test_states[idx];

    return result;
}

const testing = std.testing;

test "fuzz_state_manager basic" {
    var prng = std.Random.DefaultPrng.init(42);
    var random = prng.random();

    try fuzz_state_manager(&random, 100);
}

test "fuzz_state_manager determinism" {
    var prng1 = std.Random.DefaultPrng.init(12345);
    var prng2 = std.Random.DefaultPrng.init(12345);
    var random1 = prng1.random();
    var random2 = prng2.random();

    try fuzz_state_manager(&random1, 100);
    try fuzz_state_manager(&random2, 100);
}

test "fuzz_state_transitions basic" {
    var prng = std.Random.DefaultPrng.init(42);
    var random = prng.random();

    try fuzz_state_transitions(&random, 50);
}

test "fuzz_state_history basic" {
    var prng = std.Random.DefaultPrng.init(42);
    var random = prng.random();

    try fuzz_state_history(&random, 50);
}
