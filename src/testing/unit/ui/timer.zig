const std = @import("std");
const testing = std.testing;

const source = @import("wisp").ui.timer;

const Entry = source.Entry;
const TimerManager = source.TimerManager;

test "Entry.init creates entry with zero tick count" {
    const wisp = @import("wisp");

    const entry = Entry.init(.{
        .hwnd = null,
        .id = 1,
        .interval_ms = 1000,
    });

    try testing.expectEqual(@as(u64, 0), entry.tick_count);
    try testing.expectEqual(@as(u32, 1), entry.timer.id);
    try testing.expectEqual(@as(u32, 1000), entry.timer.interval_ms);
    try testing.expectEqual(wisp.TimerState.stopped, entry.timer.state);
}

test "TimerManager.init creates empty manager" {
    const manager = TimerManager.init();

    try testing.expectEqual(@as(u8, 0), manager.count);
    try testing.expect(manager.hwnd == null);
    try testing.expect(!manager.is_bound());
}

test "TimerManager.is_bound returns false when hwnd is null" {
    const manager = TimerManager.init();

    try testing.expect(!manager.is_bound());
}

test "TimerManager.get_tick_count returns zero for unknown id" {
    const manager = TimerManager.init();

    const count = manager.get_tick_count(999);

    try testing.expectEqual(@as(u64, 0), count);
}

test "TimerManager.is_running returns false for unknown id" {
    const manager = TimerManager.init();

    const running = manager.is_running(999);

    try testing.expect(!running);
}

test "TimerManager.start returns error when not bound" {
    var manager = TimerManager.init();
    defer manager.deinit();

    const result = manager.start(1, 1000);

    try testing.expectError(source.Error.NotBound, result);
}

test "TimerManager.stop returns error for unknown id" {
    var manager = TimerManager.init();
    defer manager.deinit();

    const result = manager.stop(999);

    try testing.expectError(source.Error.NotFound, result);
}

test "TimerManager.stop_all handles empty manager" {
    var manager = TimerManager.init();

    manager.stop_all();

    try testing.expectEqual(@as(u8, 0), manager.count);
}

test "TimerManager.deinit resets count" {
    var manager = TimerManager.init();

    manager.deinit();

    try testing.expectEqual(@as(u8, 0), manager.count);
}

test "TimerManager.reset_tick_count handles unknown id gracefully" {
    var manager = TimerManager.init();
    defer manager.deinit();

    manager.reset_tick_count(999);

    try testing.expectEqual(@as(u8, 0), manager.count);
}

test "TimerManager.handle_tick handles unknown id gracefully" {
    var manager = TimerManager.init();
    defer manager.deinit();

    manager.handle_tick(999);

    try testing.expectEqual(@as(u8, 0), manager.count);
}
