const std = @import("std");
const testing = std.testing;

const w32 = @import("win32").everything;

const source = @import("wisp").win32.menu;

const ItemInfo = source.ItemInfo;
const ItemOptions = source.ItemOptions;
const ItemState = source.ItemState;
const ItemType = source.ItemType;
const Menu = source.Menu;
const ShowOptions = source.ShowOptions;

test "ItemType enum values" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(ItemType.bitmap));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(ItemType.owner_draw));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(ItemType.separator));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(ItemType.string));
}

test "ItemState defaults to unchecked enabled" {
    const state = ItemState{};

    try testing.expect(!state.checked);
    try testing.expect(!state.default_item);
    try testing.expect(!state.disabled);
    try testing.expect(!state.grayed);
    try testing.expect(!state.hilite);
}

test "ItemState.to_uint returns zero for defaults" {
    const state = ItemState{};

    try testing.expectEqual(@as(u32, 0), state.to_uint());
}

test "ItemState.to_uint sets checked flag" {
    const state = ItemState{ .checked = true };

    try testing.expectEqual(@as(u32, 0x0008), state.to_uint());
}

test "ItemState.to_uint sets disabled flag" {
    const state = ItemState{ .disabled = true };

    try testing.expectEqual(@as(u32, 0x0002), state.to_uint());
}

test "ItemState.to_uint sets grayed flag" {
    const state = ItemState{ .grayed = true };

    try testing.expectEqual(@as(u32, 0x0001), state.to_uint());
}

test "ItemState.to_uint sets hilite flag" {
    const state = ItemState{ .hilite = true };

    try testing.expectEqual(@as(u32, 0x0080), state.to_uint());
}

test "ItemState.to_uint sets default_item flag" {
    const state = ItemState{ .default_item = true };

    try testing.expectEqual(@as(u32, 0x1000), state.to_uint());
}

test "ItemState.to_uint combines flags" {
    const state = ItemState{
        .checked = true,
        .hilite = true,
    };

    try testing.expectEqual(@as(u32, 0x0088), state.to_uint());
}

test "ItemState.from_uint parses checked" {
    const state = ItemState.from_uint(0x0008);

    try testing.expect(state.checked);
}

test "ItemState.from_uint parses disabled" {
    const state = ItemState.from_uint(0x0002);

    try testing.expect(state.disabled);
}

test "ItemState.from_uint parses grayed" {
    const state = ItemState.from_uint(0x0001);

    try testing.expect(state.grayed);
}

test "ItemState.from_uint parses hilite" {
    const state = ItemState.from_uint(0x0080);

    try testing.expect(state.hilite);
}

test "ItemOptions defaults" {
    const options = ItemOptions{};

    try testing.expectEqual(ItemType.string, options.item_type);
    try testing.expectEqual(@as(u32, 0), options.id);
    try testing.expectEqual(@as(usize, 0), options.label.len);
    try testing.expect(options.sub == null);
    try testing.expect(!options.state.checked);
    try testing.expect(!options.state.disabled);
}

test "ShowOptions defaults" {
    const options = ShowOptions{};

    try testing.expect(!options.center_align);
    try testing.expect(!options.right_align);
    try testing.expect(!options.vcenter_align);
    try testing.expect(!options.bottom_align);
    try testing.expect(!options.no_notify);
    try testing.expect(options.return_command);
    try testing.expect(!options.recurse);
    try testing.expect(!options.horizontal_animate);
    try testing.expect(!options.vertical_animate);
    try testing.expect(!options.no_animate);
    try testing.expect(options.left_button);
    try testing.expect(!options.right_button);
    try testing.expect(options.x == null);
    try testing.expect(options.y == null);
}

test "ShowOptions.to_flags returns default flags" {
    const options = ShowOptions{};

    try testing.expectEqual(@as(u32, 0x0100), options.to_flags());
}

test "ShowOptions.to_flags sets return_command" {
    const options = ShowOptions{ .return_command = true };

    try testing.expectEqual(@as(u32, 0x0100), options.to_flags());
}

test "ShowOptions.to_flags sets center_align" {
    const options = ShowOptions{ .center_align = true };

    try testing.expectEqual(@as(u32, 0x0104), options.to_flags());
}

test "ShowOptions.to_flags combines flags" {
    const options = ShowOptions{
        .return_command = true,
        .right_button = true,
    };

    try testing.expectEqual(@as(u32, 0x0102), options.to_flags());
}

test "ItemInfo defaults" {
    const info = ItemInfo{
        .checked_bitmap = null,
        .data = 0,
        .id = 0,
        .item_type = .string,
        .label = [_]u8{0} ** source.label_max,
        .label_len = 0,
        .state = .{},
        .submenu = null,
        .unchecked_bitmap = null,
    };

    try testing.expect(info.checked_bitmap == null);
    try testing.expectEqual(@as(u64, 0), info.data);
    try testing.expectEqual(@as(u32, 0), info.id);
    try testing.expectEqual(ItemType.string, info.item_type);
}

test "ItemInfo.get_label returns empty for zero length" {
    const info = ItemInfo{
        .checked_bitmap = null,
        .data = 0,
        .id = 0,
        .item_type = .string,
        .label = [_]u8{0} ** source.label_max,
        .label_len = 0,
        .state = .{},
        .submenu = null,
        .unchecked_bitmap = null,
    };

    const label = info.get_label();

    try testing.expectEqual(@as(usize, 0), label.len);
}

test "ItemInfo.get_label returns correct slice" {
    var info = ItemInfo{
        .checked_bitmap = null,
        .data = 0,
        .id = 0,
        .item_type = .string,
        .label = [_]u8{0} ** source.label_max,
        .label_len = 4,
        .state = .{},
        .submenu = null,
        .unchecked_bitmap = null,
    };

    info.label[0] = 'T';
    info.label[1] = 'e';
    info.label[2] = 's';
    info.label[3] = 't';

    const label = info.get_label();

    try testing.expectEqualStrings("Test", label);
}
