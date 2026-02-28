const std = @import("std");
const testing = std.testing;

const source = @import("wisp").win32.tray;

const BalloonIcon = source.BalloonIcon;
const BalloonOptions = source.BalloonOptions;
const CreateOptions = source.CreateOptions;
const Event = source.Event;
const IconState = source.IconState;
const ModifyOptions = source.ModifyOptions;

test "Event.is_click returns true for click events" {
    try testing.expect(Event.left_click.is_click());
    try testing.expect(Event.middle_button_up.is_click());
    try testing.expect(Event.right_click.is_click());
}

test "Event.is_click returns false for non-click events" {
    try testing.expect(!Event.mouse_move.is_click());
    try testing.expect(!Event.left_button_down.is_click());
    try testing.expect(!Event.balloon_click.is_click());
}

test "Event.is_double_click returns true for double click events" {
    try testing.expect(Event.left_double_click.is_double_click());
    try testing.expect(Event.middle_double_click.is_double_click());
    try testing.expect(Event.right_double_click.is_double_click());
}

test "Event.is_double_click returns false for single clicks" {
    try testing.expect(!Event.left_click.is_double_click());
    try testing.expect(!Event.right_click.is_double_click());
}

test "Event.parse returns left_click for WM_LBUTTONUP" {
    const result = Event.parse(0x0202);

    try testing.expect(result != null);
    try testing.expectEqual(Event.left_click, result.?);
}

test "Event.parse returns right_click for WM_RBUTTONUP" {
    const result = Event.parse(0x0205);

    try testing.expect(result != null);
    try testing.expectEqual(Event.right_click, result.?);
}

test "Event.parse returns left_double_click for WM_LBUTTONDBLCLK" {
    const result = Event.parse(0x0203);

    try testing.expect(result != null);
    try testing.expectEqual(Event.left_double_click, result.?);
}

test "Event.parse returns mouse_move for WM_MOUSEMOVE" {
    const result = Event.parse(0x0200);

    try testing.expect(result != null);
    try testing.expectEqual(Event.mouse_move, result.?);
}

test "Event.parse returns context_menu for WM_CONTEXTMENU" {
    const result = Event.parse(0x007B);

    try testing.expect(result != null);
    try testing.expectEqual(Event.context_menu, result.?);
}

test "Event.parse returns null for unknown message" {
    const result = Event.parse(0xFFFF);

    try testing.expect(result == null);
}

test "BalloonIcon.to_flag returns correct values" {
    try testing.expectEqual(@as(u32, 0x00000003), BalloonIcon.err.to_flag());
    try testing.expectEqual(@as(u32, 0x00000001), BalloonIcon.info.to_flag());
    try testing.expectEqual(@as(u32, 0x00000000), BalloonIcon.none.to_flag());
    try testing.expectEqual(@as(u32, 0x00000004), BalloonIcon.user.to_flag());
    try testing.expectEqual(@as(u32, 0x00000002), BalloonIcon.warning.to_flag());
}

test "IconState.to_uint returns zero for defaults" {
    const state = IconState{};

    try testing.expectEqual(@as(u32, 0), state.to_uint());
}

test "IconState.to_uint sets hidden flag" {
    const state = IconState{ .hidden = true };

    try testing.expectEqual(@as(u32, 0x00000001), state.to_uint());
}

test "IconState.to_uint sets shared_icon flag" {
    const state = IconState{ .shared_icon = true };

    try testing.expectEqual(@as(u32, 0x00000002), state.to_uint());
}

test "IconState.to_uint combines flags" {
    const state = IconState{ .hidden = true, .shared_icon = true };

    try testing.expectEqual(@as(u32, 0x00000003), state.to_uint());
}

test "BalloonOptions defaults" {
    const options = BalloonOptions{};

    try testing.expectEqualStrings("", options.body);
    try testing.expectEqualStrings("", options.title);
    try testing.expectEqual(BalloonIcon.info, options.icon);
    try testing.expect(!options.large_icon);
    try testing.expect(!options.realtime);
    try testing.expect(options.respect_quiet);
    try testing.expect(!options.silent);
    try testing.expectEqual(@as(u32, 0), options.timeout_ms);
}

test "BalloonOptions custom values" {
    const options = BalloonOptions{
        .body = "Test body",
        .title = "Test title",
        .icon = .warning,
        .silent = true,
        .timeout_ms = 5000,
    };

    try testing.expectEqualStrings("Test body", options.body);
    try testing.expectEqualStrings("Test title", options.title);
    try testing.expectEqual(BalloonIcon.warning, options.icon);
    try testing.expect(options.silent);
    try testing.expectEqual(@as(u32, 5000), options.timeout_ms);
}

test "ModifyOptions defaults to null" {
    const options = ModifyOptions{};

    try testing.expect(options.callback_message == null);
    try testing.expect(options.icon == null);
    try testing.expect(options.state == null);
    try testing.expect(options.tooltip == null);
}

test "ModifyOptions with tooltip" {
    const options = ModifyOptions{
        .tooltip = "New tooltip",
    };

    try testing.expect(options.tooltip != null);
    try testing.expectEqualStrings("New tooltip", options.tooltip.?);
}

test "CreateOptions defaults" {
    const wisp = @import("wisp");

    const options = CreateOptions{
        .hwnd = @ptrFromInt(0x12345678),
    };

    try testing.expectEqual(@as(u32, wisp.win32.tray.message), options.callback_message);
    try testing.expectEqual(@as(u32, 1), options.id);
    try testing.expectEqual(@as(u32, 4), options.version);
    try testing.expectEqualStrings("", options.tooltip);
}

test "message constant is WM_APP + 1" {
    try testing.expectEqual(@as(u32, 0x8001), source.message);
}
