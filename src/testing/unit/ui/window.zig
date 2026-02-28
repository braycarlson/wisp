const std = @import("std");
const testing = std.testing;

const w32 = @import("win32").everything;

const source = @import("wisp").ui.window;

const Config = source.Config;
const WindowManager = source.WindowManager;

test "WindowManager.init creates manager with name" {
    const manager = WindowManager.init(.{ .name = "TestWindow" });

    try testing.expect(!manager.is_created());
    try testing.expect(manager.window == null);
    try testing.expect(manager.on_message == null);
}

test "WindowManager.init stores name" {
    const manager = WindowManager.init(.{ .name = "MyApp" });

    try testing.expectEqual(@as(u8, 5), manager.name_len);
    try testing.expectEqualStrings("MyApp", manager.name[0..manager.name_len]);
}

test "WindowManager.is_created returns false initially" {
    const manager = WindowManager.init(.{ .name = "Test" });

    try testing.expect(!manager.is_created());
}

test "WindowManager.get_handle returns null when not created" {
    const manager = WindowManager.init(.{ .name = "Test" });

    try testing.expect(manager.get_handle() == null);
}

test "WindowManager.get_taskbar_message returns null when not created" {
    const manager = WindowManager.init(.{ .name = "Test" });

    try testing.expect(manager.get_taskbar_message() == null);
}

test "WindowManager.destroy handles null window" {
    var manager = WindowManager.init(.{ .name = "Test" });

    manager.destroy();

    try testing.expect(manager.window == null);
}

test "WindowManager.deinit clears state" {
    var manager = WindowManager.init(.{ .name = "Test" });

    manager.deinit();

    try testing.expect(manager.window == null);
}

test "WindowManager.create returns error for empty name" {
    var manager = WindowManager.init(.{ .name = "Test" });
    manager.name_len = 0;

    const result = manager.create();

    try testing.expectError(source.Error.InvalidName, result);
}

test "WindowManager name converts to wide string" {
    const manager = WindowManager.init(.{ .name = "Test" });

    try testing.expectEqual(@as(u16, 'T'), manager.name_wide[0]);
    try testing.expectEqual(@as(u16, 'e'), manager.name_wide[1]);
    try testing.expectEqual(@as(u16, 's'), manager.name_wide[2]);
    try testing.expectEqual(@as(u16, 't'), manager.name_wide[3]);
    try testing.expectEqual(@as(u16, 0), manager.name_wide[4]);
}

test "WindowManager.set_message_callback stores callback" {
    var manager = WindowManager.init(.{ .name = "Test" });

    const callback = struct {
        fn cb(_: w32.HWND, _: u32, _: w32.WPARAM, _: w32.LPARAM, _: ?*anyopaque) ?w32.LRESULT {
            return null;
        }
    }.cb;

    manager.set_message_callback(callback, null);

    try testing.expect(manager.on_message != null);
}

test "WindowManager.set_message_callback stores context" {
    var manager = WindowManager.init(.{ .name = "Test" });
    var data: u32 = 42;

    const callback = struct {
        fn cb(_: w32.HWND, _: u32, _: w32.WPARAM, _: w32.LPARAM, _: ?*anyopaque) ?w32.LRESULT {
            return null;
        }
    }.cb;

    manager.set_message_callback(callback, &data);

    try testing.expect(manager.message_context != null);
}
