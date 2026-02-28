const std = @import("std");
const testing = std.testing;

const source = @import("wisp").ui.state;

const StateManager = source.StateManager;

test "StateManager.init creates empty manager" {
    const manager = StateManager.init();

    try testing.expect(manager.is_empty());
    try testing.expectEqual(@as(u8, 0), manager.current_len);
    try testing.expectEqual(@as(u8, 0), manager.previous_len);
    try testing.expectEqual(@as(u8, 0), manager.history_count);
}

test "StateManager.set changes current state" {
    var manager = StateManager.init();
    defer manager.deinit();

    try manager.set("active");

    try testing.expect(!manager.is_empty());
    try testing.expectEqualStrings("active", manager.get());
}

test "StateManager.set updates previous state" {
    var manager = StateManager.init();
    defer manager.deinit();

    try manager.set("idle");
    try manager.set("active");

    try testing.expectEqualStrings("active", manager.get());
    try testing.expectEqualStrings("idle", manager.get_previous());
}

test "StateManager.set ignores duplicate state" {
    var manager = StateManager.init();
    defer manager.deinit();

    try manager.set("active");
    try manager.set("active");

    try testing.expectEqual(@as(u8, 1), manager.history_count);
}

test "StateManager.set returns error for empty state" {
    var manager = StateManager.init();
    defer manager.deinit();

    const result = manager.set("");

    try testing.expectError(source.Error.InvalidState, result);
}

test "StateManager.set returns error for state exceeding max length" {
    var manager = StateManager.init();
    defer manager.deinit();

    var long_state: [source.state_max]u8 = undefined;
    var index: u8 = 0;

    while (index < source.state_max) : (index += 1) {
        std.debug.assert(index < source.state_max);

        long_state[index] = 'a';
    }

    const result = manager.set(&long_state);

    try testing.expectError(source.Error.InvalidState, result);
}

test "StateManager.equals returns true for matching state" {
    var manager = StateManager.init();
    defer manager.deinit();

    try manager.set("active");

    try testing.expect(manager.equals("active"));
}

test "StateManager.equals returns false for non-matching state" {
    var manager = StateManager.init();
    defer manager.deinit();

    try manager.set("active");

    try testing.expect(!manager.equals("idle"));
}

test "StateManager.equals returns false for different length" {
    var manager = StateManager.init();
    defer manager.deinit();

    try manager.set("active");

    try testing.expect(!manager.equals("act"));
    try testing.expect(!manager.equals("activex"));
}

test "StateManager.is_one_of returns true when state matches any" {
    var manager = StateManager.init();
    defer manager.deinit();

    try manager.set("running");

    const states = [_][]const u8{ "idle", "running", "stopped" };
    const result = manager.is_one_of(&states);

    try testing.expect(result);
}

test "StateManager.is_one_of returns false when state matches none" {
    var manager = StateManager.init();
    defer manager.deinit();

    try manager.set("paused");

    const states = [_][]const u8{ "idle", "running", "stopped" };
    const result = manager.is_one_of(&states);

    try testing.expect(!result);
}

test "StateManager.get_history returns recorded transitions" {
    var manager = StateManager.init();
    defer manager.deinit();

    try manager.set("idle");
    try manager.set("active");
    try manager.set("stopped");

    const history = manager.get_history();

    try testing.expectEqual(@as(u8, 3), manager.history_count);
    try testing.expect(history.len >= 3);
}

test "StateManager.clear_history resets history" {
    var manager = StateManager.init();
    defer manager.deinit();

    try manager.set("idle");
    try manager.set("active");

    try testing.expect(manager.history_count > 0);

    manager.clear_history();

    try testing.expectEqual(@as(u8, 0), manager.history_count);
    try testing.expectEqual(@as(u8, 0), manager.history_index);
}

test "StateManager history wraps at max capacity" {
    var manager = StateManager.init();
    defer manager.deinit();

    var index: u8 = 0;

    while (index < source.history_max + 2) : (index += 1) {
        std.debug.assert(index < source.history_max + 2);

        var name: [8]u8 = undefined;
        const formatted = std.fmt.bufPrint(&name, "{d}", .{index}) catch continue;

        try manager.set(formatted);
    }

    try testing.expectEqual(source.history_max, manager.history_count);
}

test "StateManager.deinit resets all state" {
    var manager = StateManager.init();

    try manager.set("active");

    manager.deinit();

    try testing.expectEqual(@as(u8, 0), manager.current_len);
    try testing.expectEqual(@as(u8, 0), manager.previous_len);
    try testing.expectEqual(@as(u8, 0), manager.history_count);
}

test "StateManager transitions preserve data integrity" {
    var manager = StateManager.init();
    defer manager.deinit();

    const states = [_][]const u8{ "init", "loading", "ready", "active", "idle" };

    var index: u8 = 0;

    while (index < states.len) : (index += 1) {
        std.debug.assert(index < states.len);

        try manager.set(states[index]);
        try testing.expectEqualStrings(states[index], manager.get());
    }
}
