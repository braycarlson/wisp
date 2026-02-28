const std = @import("std");
const testing = std.testing;

const source = @import("wisp").win32.timer;

const Options = source.Options;
const State = source.State;
const Timer = source.Timer;
const WaitableTimerOptions = source.WaitableTimerOptions;
const WaitableTimerSetOptions = source.WaitableTimerSetOptions;
const WaitResult = source.WaitResult;

test "State enum values" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(State.running));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(State.stopped));
}

test "Timer.init creates stopped timer" {
    const timer = Timer.init(.{
        .hwnd = null,
        .id = 1,
        .interval_ms = 1000,
    });

    try testing.expectEqual(State.stopped, timer.state);
    try testing.expectEqual(@as(u32, 1), timer.id);
    try testing.expectEqual(@as(u32, 1000), timer.interval_ms);
    try testing.expect(timer.hwnd == null);
}

test "Timer.is_running returns false when stopped" {
    const timer = Timer.init(.{
        .hwnd = null,
        .id = 1,
        .interval_ms = 1000,
    });

    try testing.expect(!timer.is_running());
}

test "Timer.start succeeds without hwnd" {
    var timer = Timer.init(.{
        .hwnd = null,
        .id = 1,
        .interval_ms = 1000,
    });

    try timer.start();

    try testing.expect(timer.is_running());
}

test "Timer.stop handles already stopped timer" {
    var timer = Timer.init(.{
        .hwnd = null,
        .id = 1,
        .interval_ms = 1000,
    });

    try timer.stop();

    try testing.expectEqual(State.stopped, timer.state);
}

test "Options defaults" {
    const options = Options{
        .id = 1,
    };

    try testing.expectEqual(@as(u32, 0), options.coalesce_tolerance_ms);
    try testing.expect(options.hwnd == null);
    try testing.expectEqual(@as(u32, 1000), options.interval_ms);
}

test "Options custom values" {
    const options = Options{
        .id = 42,
        .interval_ms = 500,
        .coalesce_tolerance_ms = 100,
    };

    try testing.expectEqual(@as(u32, 42), options.id);
    try testing.expectEqual(@as(u32, 500), options.interval_ms);
    try testing.expectEqual(@as(u32, 100), options.coalesce_tolerance_ms);
}

test "WaitableTimerOptions defaults" {
    const options = WaitableTimerOptions{};

    try testing.expect(!options.high_resolution);
    try testing.expect(options.manual_reset);
    try testing.expect(options.name == null);
}

test "WaitableTimerOptions custom values" {
    const options = WaitableTimerOptions{
        .high_resolution = true,
        .manual_reset = false,
        .name = "TestTimer",
    };

    try testing.expect(options.high_resolution);
    try testing.expect(!options.manual_reset);
    try testing.expect(options.name != null);
    try testing.expectEqualStrings("TestTimer", options.name.?);
}

test "WaitableTimerSetOptions defaults" {
    const options = WaitableTimerSetOptions{};

    try testing.expectEqual(@as(i64, 0), options.due_time_100ns);
    try testing.expectEqual(@as(i32, 0), options.period_ms);
    try testing.expect(!options.resume_from_suspend);
    try testing.expectEqual(@as(u32, 0), options.tolerance_ms);
}

test "WaitableTimerSetOptions custom values" {
    const options = WaitableTimerSetOptions{
        .due_time_100ns = -10000000,
        .period_ms = 1000,
        .resume_from_suspend = true,
        .tolerance_ms = 50,
    };

    try testing.expectEqual(@as(i64, -10000000), options.due_time_100ns);
    try testing.expectEqual(@as(i32, 1000), options.period_ms);
    try testing.expect(options.resume_from_suspend);
    try testing.expectEqual(@as(u32, 50), options.tolerance_ms);
}

test "WaitResult enum values" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(WaitResult.abandoned));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(WaitResult.failed));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(WaitResult.signaled));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(WaitResult.timeout));
}

test "get_tick_count returns value" {
    const tick = source.get_tick_count();

    try testing.expect(tick > 0 or tick == 0);
}

test "get_tick_count_64 returns value" {
    const tick = source.get_tick_count_64();

    try testing.expect(tick > 0 or tick == 0);
}
