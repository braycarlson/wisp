const std = @import("std");
const testing = std.testing;

const source = @import("wisp").win32.watcher.watcher;

const Watcher = source.Watcher;

test "Watcher.init creates stopped watcher" {
    const watcher = Watcher.init();

    try testing.expect(!watcher.is_running());
    try testing.expect(watcher.thread == null);
    try testing.expect(watcher.directory == null);
    try testing.expect(watcher.signal_stop == null);
    try testing.expect(watcher.callback == null);
}

test "Watcher.is_running returns false initially" {
    const watcher = Watcher.init();

    try testing.expect(!watcher.is_running());
}

test "Watcher.stop handles already stopped watcher" {
    var watcher = Watcher.init();

    watcher.stop();

    try testing.expect(!watcher.is_running());
    try testing.expect(watcher.thread == null);
}

test "Watcher.deinit clears state" {
    var watcher = Watcher.init();

    watcher.deinit();

    try testing.expect(!watcher.is_running());
}

test "Watcher.watch returns error for empty path" {
    var watcher = Watcher.init();
    defer watcher.deinit();

    const callback = struct {
        fn cb() void {}
    }.cb;

    const result = watcher.watch("", callback);

    try testing.expectError(source.Error.InvalidPath, result);
}

test "Watcher.watch returns error for path without directory" {
    var watcher = Watcher.init();
    defer watcher.deinit();

    const callback = struct {
        fn cb() void {}
    }.cb;

    const result = watcher.watch("filename_only", callback);

    try testing.expectError(source.Error.InvalidPath, result);
}

test "Watcher callback type is valid" {
    const callback_info = @typeInfo(source.Callback);

    try testing.expect(callback_info == .pointer);
}
