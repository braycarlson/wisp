const std = @import("std");
const testing = std.testing;

const source = @import("wisp").win32.icon;

const DrawOptions = source.DrawOptions;
const Icon = source.Icon;
const IconInfo = source.IconInfo;
const LoadOptions = source.LoadOptions;
const Source = source.Source;
const System = source.System;

test "System.to_resource returns valid pointers" {
    const app_resource = System.application.to_resource();
    const shield_resource = System.shield.to_resource();

    try testing.expect(@intFromPtr(app_resource) != 0);
    try testing.expect(@intFromPtr(shield_resource) != 0);
    try testing.expect(@intFromPtr(app_resource) != @intFromPtr(shield_resource));
}

test "DrawOptions.DrawFlags.to_uint returns zero for defaults" {
    const flags = DrawOptions.DrawFlags{};

    try testing.expectEqual(@as(u32, 0), flags.to_uint());
}

test "DrawOptions.DrawFlags.to_uint sets mask flag" {
    const flags = DrawOptions.DrawFlags{ .mask = true };

    try testing.expectEqual(@as(u32, 0x0001), flags.to_uint());
}

test "DrawOptions.DrawFlags.to_uint sets image flag" {
    const flags = DrawOptions.DrawFlags{ .image = true };

    try testing.expectEqual(@as(u32, 0x0002), flags.to_uint());
}

test "DrawOptions.DrawFlags.to_uint sets default_size flag" {
    const flags = DrawOptions.DrawFlags{ .default_size = true };

    try testing.expectEqual(@as(u32, 0x0008), flags.to_uint());
}

test "DrawOptions.DrawFlags.to_uint sets disabled flag" {
    const flags = DrawOptions.DrawFlags{ .disabled = true };

    try testing.expectEqual(@as(u32, 0x0100), flags.to_uint());
}

test "DrawOptions.DrawFlags.to_uint sets transparent flag" {
    const flags = DrawOptions.DrawFlags{ .transparent = true };

    try testing.expectEqual(@as(u32, 0x0200), flags.to_uint());
}

test "DrawOptions.DrawFlags.to_uint combines multiple flags" {
    const flags = DrawOptions.DrawFlags{
        .mask = true,
        .image = true,
        .default_size = true,
    };

    try testing.expectEqual(@as(u32, 0x000B), flags.to_uint());
}

test "Icon.is_valid returns true for non-null handle" {
    const icon = Icon{
        .handle = @ptrFromInt(0x12345678),
        .owned = true,
    };

    try testing.expect(icon.is_valid());
}

test "Icon.deinit returns true for unowned icon" {
    const icon = Icon{
        .handle = @ptrFromInt(0x12345678),
        .owned = false,
    };

    const result = icon.deinit();

    try testing.expect(result);
}

test "IconInfo.deinit handles null bitmaps" {
    var info = IconInfo{
        .color_bitmap = null,
        .hotspot_x = 0,
        .hotspot_y = 0,
        .is_icon = true,
        .mask_bitmap = null,
    };

    info.deinit();

    try testing.expect(info.color_bitmap == null);
    try testing.expect(info.mask_bitmap == null);
}

test "Source.resource stores id" {
    const src = Source{ .resource = .{ .id = 100, .instance = null } };

    switch (src) {
        .resource => |r| {
            try testing.expectEqual(@as(u32, 100), r.id);
            try testing.expect(r.instance == null);
        },
        else => try testing.expect(false),
    }
}

test "Source.system stores system type" {
    const src = Source{ .system = .application };

    switch (src) {
        .system => |s| {
            try testing.expectEqual(System.application, s);
        },
        else => try testing.expect(false),
    }
}

test "Source.file stores path" {
    const src = Source{ .file = .{ .path = "test.ico" } };

    switch (src) {
        .file => |f| {
            try testing.expectEqualStrings("test.ico", f.path);
        },
        else => try testing.expect(false),
    }
}

test "LoadOptions defaults" {
    const options = LoadOptions{
        .source = .{ .system = .application },
    };

    try testing.expect(options.default_size);
    try testing.expect(!options.shared);
    try testing.expectEqual(@as(u32, 0), options.width);
    try testing.expectEqual(@as(u32, 0), options.height);
}

test "DrawOptions defaults" {
    const options = DrawOptions{
        .hdc = @ptrFromInt(0x12345678),
    };

    try testing.expect(options.background == null);
    try testing.expect(options.foreground == null);
    try testing.expectEqual(@as(u32, 0), options.frame_index);
    try testing.expectEqual(@as(u32, 0), options.height);
    try testing.expectEqual(@as(u32, 0), options.width);
    try testing.expectEqual(@as(i32, 0), options.x);
    try testing.expectEqual(@as(i32, 0), options.y);
}
