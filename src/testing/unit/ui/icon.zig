const std = @import("std");
const testing = std.testing;

const source = @import("wisp").ui.icon;

const Entry = source.Entry;
const IconManager = source.IconManager;
const Source = source.Source;

test "Entry.init creates entry with name and source" {
    const entry = Entry.init("test_icon", .{ .resource = 100 });

    try testing.expectEqualStrings("test_icon", entry.get_name());
    try testing.expect(entry.icon == null);
}

test "Entry.get_name returns stored name" {
    const entry = Entry.init("my_icon", .{ .resource = 1 });

    try testing.expectEqualStrings("my_icon", entry.get_name());
}

test "Entry.matches returns true for matching name" {
    const entry = Entry.init("icon", .{ .resource = 1 });

    try testing.expect(entry.matches("icon"));
}

test "Entry.matches returns false for non-matching name" {
    const entry = Entry.init("icon", .{ .resource = 1 });

    try testing.expect(!entry.matches("other"));
}

test "Entry.matches returns false for different length" {
    const entry = Entry.init("icon", .{ .resource = 1 });

    try testing.expect(!entry.matches("ico"));
    try testing.expect(!entry.matches("iconx"));
}

test "Entry.deinit clears icon" {
    var entry = Entry.init("test", .{ .resource = 1 });

    entry.deinit();

    try testing.expect(entry.icon == null);
}

test "Source.resource stores id" {
    const src = Source{ .resource = 100 };

    switch (src) {
        .resource => |id| {
            try testing.expectEqual(@as(u32, 100), id);
        },
        .system => try testing.expect(false),
    }
}

test "Source.system stores system type" {
    const wisp = @import("wisp");
    const src = Source{ .system = wisp.IconSystem.application };

    switch (src) {
        .system => |s| {
            try testing.expectEqual(wisp.IconSystem.application, s);
        },
        .resource => try testing.expect(false),
    }
}

test "IconManager.init creates empty manager" {
    const manager = IconManager.init();

    try testing.expect(manager.is_empty());
    try testing.expectEqual(@as(u8, 0), manager.count);
}

test "IconManager.add creates entry" {
    var manager = IconManager.init();
    defer manager.deinit();

    try manager.add("test_icon", .{ .resource = 100 });

    try testing.expectEqual(@as(u8, 1), manager.count);
}

test "IconManager.add returns error for duplicate name" {
    var manager = IconManager.init();
    defer manager.deinit();

    try manager.add("icon", .{ .resource = 1 });

    const result = manager.add("icon", .{ .resource = 2 });

    try testing.expectError(source.Error.DuplicateName, result);
}

test "IconManager.add returns error for empty name" {
    var manager = IconManager.init();
    defer manager.deinit();

    const result = manager.add("", .{ .resource = 1 });

    try testing.expectError(source.Error.InvalidName, result);
}

test "IconManager.add returns error at capacity" {
    var manager = IconManager.init();
    defer manager.deinit();

    var index: u8 = 0;

    while (index < source.icon_max) : (index += 1) {
        std.debug.assert(index < source.icon_max);

        var name: [8]u8 = undefined;
        const formatted = std.fmt.bufPrint(&name, "{d}", .{index}) catch continue;

        try manager.add(formatted, .{ .resource = index });
    }

    const result = manager.add("overflow", .{ .resource = 255 });

    try testing.expectError(source.Error.CapacityExceeded, result);
}

test "IconManager.add_resource adds resource entry" {
    var manager = IconManager.init();
    defer manager.deinit();

    try manager.add_resource("icon", 100);

    try testing.expectEqual(@as(u8, 1), manager.count);
}

test "IconManager.add_system adds system entry" {
    var manager = IconManager.init();
    defer manager.deinit();

    const wisp = @import("wisp");

    try manager.add_system("app", wisp.IconSystem.application);

    try testing.expectEqual(@as(u8, 1), manager.count);
}

test "IconManager.get_current_name returns null when empty" {
    const manager = IconManager.init();

    try testing.expect(manager.get_current_name() == null);
}

test "IconManager.get_current returns null when not loaded" {
    var manager = IconManager.init();
    defer manager.deinit();

    try manager.add("icon", .{ .resource = 1 });

    try testing.expect(manager.get_current() == null);
}

test "IconManager.set_current returns error for unknown name" {
    var manager = IconManager.init();
    defer manager.deinit();

    try manager.add("icon1", .{ .resource = 1 });

    const result = manager.set_current("unknown");

    try testing.expectError(source.Error.NotFound, result);
}

test "IconManager.set_current updates current index" {
    var manager = IconManager.init();
    defer manager.deinit();

    try manager.add("icon1", .{ .resource = 1 });
    try manager.add("icon2", .{ .resource = 2 });

    try manager.set_current("icon2");

    try testing.expectEqual(@as(u8, 1), manager.current);
}

test "IconManager.set_current ignores same icon" {
    var manager = IconManager.init();
    defer manager.deinit();

    try manager.add("icon1", .{ .resource = 1 });

    manager.current = 0;

    try manager.set_current("icon1");

    try testing.expectEqual(@as(u8, 0), manager.current);
}

test "IconManager.is_empty returns correct state" {
    var manager = IconManager.init();
    defer manager.deinit();

    try testing.expect(manager.is_empty());

    try manager.add("icon", .{ .resource = 1 });

    try testing.expect(!manager.is_empty());
}

test "IconManager.is_loaded returns correct state" {
    var manager = IconManager.init();
    defer manager.deinit();

    try testing.expect(!manager.is_loaded());
}

test "IconManager.deinit clears all entries" {
    var manager = IconManager.init();

    try manager.add("icon1", .{ .resource = 1 });
    try manager.add("icon2", .{ .resource = 2 });

    manager.deinit();

    try testing.expect(manager.is_empty());
    try testing.expectEqual(@as(u8, 0), manager.count);
    try testing.expect(!manager.is_loaded());
}

test "IconManager multiple adds and lookups" {
    var manager = IconManager.init();
    defer manager.deinit();

    try manager.add("first", .{ .resource = 1 });
    try manager.add("second", .{ .resource = 2 });
    try manager.add("third", .{ .resource = 3 });

    try testing.expectEqual(@as(u8, 3), manager.count);

    try manager.set_current("second");

    try testing.expectEqual(@as(u8, 1), manager.current);
}
