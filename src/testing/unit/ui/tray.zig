const std = @import("std");
const testing = std.testing;

const source = @import("wisp").ui.tray;
const win32 = @import("wisp").win32;

const BalloonIcon = source.BalloonIcon;
const Config = source.Config;
const TrayManager = source.TrayManager;

test "BalloonIcon.to_interface converts correctly" {
    try testing.expectEqual(win32.TrayBalloonIcon.err, BalloonIcon.err.to_interface());
    try testing.expectEqual(win32.TrayBalloonIcon.info, BalloonIcon.info.to_interface());
    try testing.expectEqual(win32.TrayBalloonIcon.none, BalloonIcon.none.to_interface());
    try testing.expectEqual(win32.TrayBalloonIcon.warning, BalloonIcon.warning.to_interface());
}

test "TrayManager.init creates manager with tooltip" {
    const manager = TrayManager.init(.{ .tooltip = "Test Tooltip" });

    try testing.expectEqualStrings("Test Tooltip", manager.get_tooltip());
    try testing.expect(!manager.is_created());
    try testing.expect(manager.hwnd == null);
}

test "TrayManager.init stores id" {
    const manager = TrayManager.init(.{ .id = 42, .tooltip = "Test" });

    try testing.expectEqual(@as(u32, 42), manager.get_id());
}

test "TrayManager.init uses default id" {
    const manager = TrayManager.init(.{ .tooltip = "Test" });

    try testing.expectEqual(@as(u32, 1), manager.get_id());
}

test "TrayManager.get_tooltip returns stored tooltip" {
    const manager = TrayManager.init(.{ .tooltip = "My Application" });

    try testing.expectEqualStrings("My Application", manager.get_tooltip());
}

test "TrayManager.get_id returns stored id" {
    const manager = TrayManager.init(.{ .id = 5, .tooltip = "Test" });

    try testing.expectEqual(@as(u32, 5), manager.get_id());
}

test "TrayManager.is_created returns false initially" {
    const manager = TrayManager.init(.{ .tooltip = "Test" });

    try testing.expect(!manager.is_created());
}

test "TrayManager.destroy handles null tray" {
    var manager = TrayManager.init(.{ .tooltip = "Test" });

    manager.destroy();

    try testing.expect(!manager.is_created());
}

test "TrayManager.deinit clears state" {
    var manager = TrayManager.init(.{ .tooltip = "Test" });

    manager.deinit();

    try testing.expect(manager.tray == null);
    try testing.expect(manager.hwnd == null);
    try testing.expect(manager.service == null);
}

test "TrayManager.set_tooltip returns error when invalid" {
    var manager = TrayManager.init(.{ .tooltip = "Test" });
    defer manager.deinit();

    const result = manager.set_tooltip("");

    try testing.expectError(source.Error.InvalidTooltip, result);
}

test "TrayManager.set_tooltip updates tooltip" {
    var manager = TrayManager.init(.{ .tooltip = "Old" });
    defer manager.deinit();

    try manager.set_tooltip("New Tooltip");

    try testing.expectEqualStrings("New Tooltip", manager.get_tooltip());
}

test "TrayManager.show_balloon returns error when not bound" {
    var manager = TrayManager.init(.{ .tooltip = "Test" });
    defer manager.deinit();

    const result = manager.show_balloon("Title", "Body", .info);

    try testing.expectError(source.Error.NotBound, result);
}

test "TrayManager.hide_balloon returns error when not bound" {
    var manager = TrayManager.init(.{ .tooltip = "Test" });
    defer manager.deinit();

    const result = manager.hide_balloon();

    try testing.expectError(source.Error.NotBound, result);
}

test "TrayManager.set_icon returns error when not bound" {
    var manager = TrayManager.init(.{ .tooltip = "Test" });
    defer manager.deinit();

    const wisp = @import("wisp");
    var icon = wisp.Icon{ .handle = undefined, .owned = false };

    const result = manager.set_icon(&icon);

    try testing.expectError(source.Error.NotBound, result);
}

test "TrayManager.recreate returns error when not bound" {
    var manager = TrayManager.init(.{ .tooltip = "Test" });
    defer manager.deinit();

    const wisp = @import("wisp");
    var icon = wisp.Icon{ .handle = undefined, .owned = false };

    const result = manager.recreate(&icon);

    try testing.expectError(source.Error.NotBound, result);
}
