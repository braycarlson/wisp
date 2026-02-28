const std = @import("std");
const testing = std.testing;

const source = @import("wisp").event;
const types = @import("wisp").event.types;

const Event = source.Event;
const Kind = source.Kind;
const Payload = types.Payload;
const Response = source.Response;

test "Kind.is_valid returns true for all defined kinds" {
    const kinds = [_]Kind{
        .app_init,
        .app_shutdown,
        .custom,
        .icon_change,
        .menu_select,
        .menu_show,
        .state_change,
        .taskbar_restart,
        .timer_tick,
        .tray_double_click,
        .tray_left_click,
        .tray_right_click,
        .window_message,
    };

    var index: u8 = 0;

    while (index < kinds.len) : (index += 1) {
        std.debug.assert(index < kinds.len);

        const kind = kinds[index];
        const result = kind.is_valid();

        try testing.expect(result);
    }
}

test "Response.should_quit returns true only for quit" {
    try testing.expect(!Response.pass.should_quit());
    try testing.expect(!Response.handled.should_quit());
    try testing.expect(Response.quit.should_quit());
}

test "Response.should_stop returns true for handled and quit" {
    try testing.expect(!Response.pass.should_stop());
    try testing.expect(Response.handled.should_stop());
    try testing.expect(Response.quit.should_stop());
}

test "Event.app_init creates correct event" {
    const event = Event.app_init();

    try testing.expectEqual(Kind.app_init, event.kind);
    try testing.expect(event.timestamp_ms != 0);
}

test "Event.app_shutdown creates correct event" {
    const event = Event.app_shutdown();

    try testing.expectEqual(Kind.app_shutdown, event.kind);
    try testing.expect(event.timestamp_ms != 0);
}

test "Event.custom creates event with code and data" {
    const code: u32 = 42;
    const event = Event.custom(code, null);

    try testing.expectEqual(Kind.custom, event.kind);
    try testing.expectEqual(code, event.payload.custom.code);
    try testing.expectEqual(@as(?*anyopaque, null), event.payload.custom.data);
}

test "Event.icon_change creates event with name" {
    const name = "test_icon";
    const event = Event.icon_change(name);

    try testing.expectEqual(Kind.icon_change, event.kind);
    try testing.expectEqualStrings(name, event.payload.icon_change.name);
}

test "Event.menu_select creates event with id and checked" {
    const id: u32 = 100;
    const checked = true;
    const event = Event.menu_select(id, checked);

    try testing.expectEqual(Kind.menu_select, event.kind);
    try testing.expectEqual(id, event.payload.menu_select.id);
    try testing.expectEqual(checked, event.payload.menu_select.checked);
}

test "Event.menu_show creates correct event" {
    const event = Event.menu_show();

    try testing.expectEqual(Kind.menu_show, event.kind);
}

test "Event.state_change creates event with from and to" {
    const from = "idle";
    const to = "active";
    const event = Event.state_change(from, to);

    try testing.expectEqual(Kind.state_change, event.kind);
    try testing.expectEqualStrings(from, event.payload.state_change.from);
    try testing.expectEqualStrings(to, event.payload.state_change.to);
}

test "Event.taskbar_restart creates correct event" {
    const event = Event.taskbar_restart();

    try testing.expectEqual(Kind.taskbar_restart, event.kind);
}

test "Event.timer_tick creates event with id and tick_count" {
    const id: u32 = 1;
    const tick_count: u64 = 100;
    const event = Event.timer_tick(id, tick_count);

    try testing.expectEqual(Kind.timer_tick, event.kind);
    try testing.expectEqual(id, event.payload.timer_tick.id);
    try testing.expectEqual(tick_count, event.payload.timer_tick.tick_count);
}

test "Event.tray_double_click creates correct event" {
    const event = Event.tray_double_click();

    try testing.expectEqual(Kind.tray_double_click, event.kind);
}

test "Event.tray_left_click creates correct event" {
    const event = Event.tray_left_click();

    try testing.expectEqual(Kind.tray_left_click, event.kind);
}

test "Event.tray_right_click creates correct event" {
    const event = Event.tray_right_click();

    try testing.expectEqual(Kind.tray_right_click, event.kind);
}

test "Event.window_message creates event with message parameters" {
    const message: u32 = 0x0010;
    const wparam: u64 = 1;
    const lparam: i64 = -1;
    const event = Event.window_message(message, wparam, lparam);

    try testing.expectEqual(Kind.window_message, event.kind);
    try testing.expectEqual(message, event.payload.window_message.message);
    try testing.expectEqual(wparam, event.payload.window_message.wparam);
    try testing.expectEqual(lparam, event.payload.window_message.lparam);
}

test "Event.create validates kind matches payload" {
    const kind = Kind.app_init;
    const payload = Payload{ .app_init = {} };
    const event = Event.create(kind, payload);

    try testing.expectEqual(kind, event.kind);
    try testing.expect(event.timestamp_ms != 0);
}

test "Event timestamps are monotonically increasing" {
    const event1 = Event.app_init();
    const event2 = Event.app_init();

    try testing.expect(event2.timestamp_ms >= event1.timestamp_ms);
}
