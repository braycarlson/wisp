const std = @import("std");
const testing = std.testing;

const source = @import("wisp").ui.notification;

const Icon = source.Icon;
const Notification = source.Notification;
const NotificationManager = source.NotificationManager;

test "Icon.to_flag returns correct values" {
    try testing.expectEqual(@as(u32, 0x00000003), Icon.err.to_flag());
    try testing.expectEqual(@as(u32, 0x00000001), Icon.info.to_flag());
    try testing.expectEqual(@as(u32, 0x00000000), Icon.none.to_flag());
    try testing.expectEqual(@as(u32, 0x00000002), Icon.warning.to_flag());
}

test "Notification.init creates notification with title and body" {
    const notification = Notification.init("Title", "Body");

    try testing.expectEqualStrings("Title", notification.get_title());
    try testing.expectEqualStrings("Body", notification.get_body());
    try testing.expectEqual(Icon.info, notification.icon);
    try testing.expect(!notification.silent);
}

test "Notification.err creates error notification" {
    const notification = Notification.err("Error", "Something went wrong");

    try testing.expectEqual(Icon.err, notification.icon);
    try testing.expectEqualStrings("Error", notification.get_title());
}

test "Notification.info creates info notification" {
    const notification = Notification.info("Info", "Information message");

    try testing.expectEqual(Icon.info, notification.icon);
}

test "Notification.warning creates warning notification" {
    const notification = Notification.warning("Warning", "Be careful");

    try testing.expectEqual(Icon.warning, notification.icon);
}

test "Notification.set_title updates title" {
    var notification = Notification.init("Old", "Body");

    notification.set_title("New Title");

    try testing.expectEqualStrings("New Title", notification.get_title());
}

test "Notification.set_title ignores empty title" {
    var notification = Notification.init("Original", "Body");

    notification.set_title("");

    try testing.expectEqualStrings("Original", notification.get_title());
}

test "Notification.set_body updates body" {
    var notification = Notification.init("Title", "Old Body");

    notification.set_body("New Body");

    try testing.expectEqualStrings("New Body", notification.get_body());
}

test "Notification.set_body ignores empty body" {
    var notification = Notification.init("Title", "Original");

    notification.set_body("");

    try testing.expectEqualStrings("Original", notification.get_body());
}

test "Notification.with_icon returns modified notification" {
    const notification = Notification.init("Title", "Body").with_icon(.warning);

    try testing.expectEqual(Icon.warning, notification.icon);
}

test "Notification.with_silent returns modified notification" {
    const notification = Notification.init("Title", "Body").with_silent(true);

    try testing.expect(notification.silent);
}

test "Notification.is_valid returns true for valid notification" {
    const notification = Notification.init("Title", "Body");

    try testing.expect(notification.is_valid());
}

test "Notification.is_valid returns false for empty title" {
    var notification = Notification.init("Title", "Body");
    notification.title_len = 0;

    try testing.expect(!notification.is_valid());
}

test "Notification.is_valid returns false for empty body" {
    var notification = Notification.init("Title", "Body");
    notification.body_len = 0;

    try testing.expect(!notification.is_valid());
}

test "NotificationManager.init creates unbound manager" {
    const manager = NotificationManager.init();

    try testing.expect(!manager.is_bound());
    try testing.expect(manager.hwnd == null);
}

test "NotificationManager.is_bound returns false when not bound" {
    const manager = NotificationManager.init();

    try testing.expect(!manager.is_bound());
}

test "NotificationManager.deinit resets manager" {
    var manager = NotificationManager.init();

    manager.deinit();

    try testing.expect(manager.hwnd == null);
    try testing.expect(manager.service == null);
}

test "Notification chaining works correctly" {
    const notification = Notification.init("Title", "Body")
        .with_icon(.err)
        .with_silent(true);

    try testing.expectEqual(Icon.err, notification.icon);
    try testing.expect(notification.silent);
    try testing.expectEqualStrings("Title", notification.get_title());
    try testing.expectEqualStrings("Body", notification.get_body());
}
