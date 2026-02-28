const std = @import("std");
const testing = std.testing;

const source = @import("wisp").win32.window;

const ClassStyle = source.ClassStyle;
const ExStyle = source.ExStyle;
const SetPosFlags = source.SetPosFlags;
const ShowCommand = source.ShowCommand;
const Style = source.Style;
const Window = source.Window;

test "Style.to_uint returns zero for none" {
    const style = Style.none();

    try testing.expectEqual(@as(u32, 0), style.to_uint());
}

test "Style.to_uint sets border flag" {
    const style = Style{ .border = true, .overlapped = false };

    try testing.expectEqual(@as(u32, 0x00800000), style.to_uint());
}

test "Style.to_uint sets caption flag" {
    const style = Style{ .caption = true, .overlapped = false };

    try testing.expectEqual(@as(u32, 0x00C00000), style.to_uint());
}

test "Style.to_uint sets visible flag" {
    const style = Style{ .visible = true, .overlapped = false };

    try testing.expectEqual(@as(u32, 0x10000000), style.to_uint());
}

test "Style.to_uint sets popup flag" {
    const style = Style{ .popup = true, .overlapped = false };

    try testing.expectEqual(@as(u32, 0x80000000), style.to_uint());
}

test "Style.to_uint sets overlapped flag" {
    const style = Style{ .overlapped = true };

    try testing.expectEqual(@as(u32, 0x00000000), style.to_uint());
}

test "Style.to_uint combines multiple flags" {
    const style = Style{
        .border = true,
        .caption = true,
        .visible = true,
        .overlapped = false,
    };

    try testing.expectEqual(@as(u32, 0x10C00000), style.to_uint());
}

test "Style.none returns zeroed style" {
    const style = Style.none();

    try testing.expect(!style.border);
    try testing.expect(!style.caption);
    try testing.expect(!style.child);
    try testing.expect(!style.clip_children);
    try testing.expect(!style.clip_siblings);
    try testing.expect(!style.disabled);
    try testing.expect(!style.dlg_frame);
    try testing.expect(!style.group);
    try testing.expect(!style.hscroll);
    try testing.expect(!style.maximize);
    try testing.expect(!style.maximize_box);
    try testing.expect(!style.minimize);
    try testing.expect(!style.minimize_box);
    try testing.expect(!style.overlapped);
    try testing.expect(!style.popup);
    try testing.expect(!style.thickframe);
    try testing.expect(!style.sysmenu);
    try testing.expect(!style.tabstop);
    try testing.expect(!style.visible);
    try testing.expect(!style.vscroll);
}

test "ExStyle.to_uint returns zero for none" {
    const style = ExStyle.none();

    try testing.expectEqual(@as(u32, 0), style.to_uint());
}

test "ExStyle.to_uint sets topmost flag" {
    const style = ExStyle{ .topmost = true };

    try testing.expectEqual(@as(u32, 0x00000008), style.to_uint());
}

test "ExStyle.to_uint sets transparent flag" {
    const style = ExStyle{ .transparent = true };

    try testing.expectEqual(@as(u32, 0x00000020), style.to_uint());
}

test "ExStyle.to_uint sets tool_window flag" {
    const style = ExStyle{ .tool_window = true };

    try testing.expectEqual(@as(u32, 0x00000080), style.to_uint());
}

test "ExStyle.to_uint sets app_window flag" {
    const style = ExStyle{ .app_window = true };

    try testing.expectEqual(@as(u32, 0x00040000), style.to_uint());
}

test "ExStyle.to_uint sets layered flag" {
    const style = ExStyle{ .layered = true };

    try testing.expectEqual(@as(u32, 0x00080000), style.to_uint());
}

test "ExStyle.none returns zeroed style" {
    const style = ExStyle.none();

    try testing.expect(!style.accept_files);
    try testing.expect(!style.app_window);
    try testing.expect(!style.client_edge);
    try testing.expect(!style.composited);
    try testing.expect(!style.context_help);
    try testing.expect(!style.control_parent);
    try testing.expect(!style.dlg_modal_frame);
    try testing.expect(!style.layered);
    try testing.expect(!style.layout_rtl);
    try testing.expect(!style.left);
    try testing.expect(!style.left_scrollbar);
    try testing.expect(!style.mdi_child);
    try testing.expect(!style.no_activate);
    try testing.expect(!style.no_inherit_layout);
    try testing.expect(!style.no_parent_notify);
    try testing.expect(!style.no_redirection_bitmap);
    try testing.expect(!style.overlapped_window);
    try testing.expect(!style.palette_window);
    try testing.expect(!style.right);
    try testing.expect(!style.right_scrollbar);
    try testing.expect(!style.rtl_reading);
    try testing.expect(!style.static_edge);
    try testing.expect(!style.tool_window);
    try testing.expect(!style.topmost);
    try testing.expect(!style.transparent);
    try testing.expect(!style.window_edge);
}

test "ClassStyle.to_uint returns zero for defaults" {
    const style = ClassStyle{};

    try testing.expectEqual(@as(u32, 0x0008), style.to_uint());
}

test "ClassStyle.to_uint sets vredraw flag" {
    const style = ClassStyle{ .vredraw = true };

    try testing.expectEqual(@as(u32, 0x0009), style.to_uint());
}

test "ClassStyle.to_uint sets hredraw flag" {
    const style = ClassStyle{ .hredraw = true };

    try testing.expectEqual(@as(u32, 0x000A), style.to_uint());
}

test "ClassStyle.to_uint sets dbl_clks flag" {
    const style = ClassStyle{ .dbl_clks = true };

    try testing.expectEqual(@as(u32, 0x0008), style.to_uint());
}

test "ClassStyle.to_uint combines flags" {
    const style = ClassStyle{
        .vredraw = true,
        .hredraw = true,
        .dbl_clks = true,
    };

    try testing.expectEqual(@as(u32, 0x000B), style.to_uint());
}

test "SetPosFlags.to_uint returns zero for defaults" {
    const flags = SetPosFlags{};

    try testing.expectEqual(@as(u32, 0), flags.to_uint());
}

test "SetPosFlags.to_uint sets no_size flag" {
    const flags = SetPosFlags{ .no_size = true };

    try testing.expectEqual(@as(u32, 0x0001), flags.to_uint());
}

test "SetPosFlags.to_uint sets no_move flag" {
    const flags = SetPosFlags{ .no_move = true };

    try testing.expectEqual(@as(u32, 0x0002), flags.to_uint());
}

test "SetPosFlags.to_uint sets no_zorder flag" {
    const flags = SetPosFlags{ .no_zorder = true };

    try testing.expectEqual(@as(u32, 0x0004), flags.to_uint());
}

test "SetPosFlags.to_uint sets no_activate flag" {
    const flags = SetPosFlags{ .no_activate = true };

    try testing.expectEqual(@as(u32, 0x0010), flags.to_uint());
}

test "SetPosFlags.to_uint combines flags" {
    const flags = SetPosFlags{
        .no_size = true,
        .no_move = true,
        .no_zorder = true,
    };

    try testing.expectEqual(@as(u32, 0x0007), flags.to_uint());
}

test "ShowCommand enum values" {
    try testing.expectEqual(@as(i32, 0), @intFromEnum(ShowCommand.hide));
    try testing.expectEqual(@as(i32, 1), @intFromEnum(ShowCommand.show_normal));
    try testing.expectEqual(@as(i32, 5), @intFromEnum(ShowCommand.show));
    try testing.expectEqual(@as(i32, 9), @intFromEnum(ShowCommand.restore));
}

test "Style.overlapped_window returns correct flags" {
    const style = Style.overlapped_window();

    try testing.expect(style.caption);
    try testing.expect(style.maximize_box);
    try testing.expect(style.minimize_box);
    try testing.expect(style.overlapped);
    try testing.expect(style.sysmenu);
    try testing.expect(style.thickframe);
}

test "Style.popup_window returns correct flags" {
    const style = Style.popup_window();

    try testing.expect(style.border);
    try testing.expect(!style.overlapped);
    try testing.expect(style.popup);
    try testing.expect(style.sysmenu);
}

test "Style.child_window returns correct flags" {
    const style = Style.child_window();

    try testing.expect(style.child);
    try testing.expect(!style.overlapped);
    try testing.expect(style.visible);
}

test "ExStyle.tool returns correct flags" {
    const style = ExStyle.tool();

    try testing.expect(style.tool_window);
}

test "ExStyle.topmost_tool returns correct flags" {
    const style = ExStyle.topmost_tool();

    try testing.expect(style.tool_window);
    try testing.expect(style.topmost);
}

test "ClassStyle.none returns zeroed style" {
    const style = ClassStyle.none();

    try testing.expect(!style.dbl_clks);
    try testing.expect(!style.vredraw);
    try testing.expect(!style.hredraw);
}
