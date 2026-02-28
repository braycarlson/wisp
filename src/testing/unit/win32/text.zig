const std = @import("std");
const testing = std.testing;

const text = @import("wisp").win32.text;

test "copy_wide copies ascii to wide buffer" {
    var buffer: [16]u16 = undefined;

    text.copy_wide(&buffer, "Hello");

    try testing.expectEqual(@as(u16, 'H'), buffer[0]);
    try testing.expectEqual(@as(u16, 'e'), buffer[1]);
    try testing.expectEqual(@as(u16, 'l'), buffer[2]);
    try testing.expectEqual(@as(u16, 'l'), buffer[3]);
    try testing.expectEqual(@as(u16, 'o'), buffer[4]);
    try testing.expectEqual(@as(u16, 0), buffer[5]);
}

test "copy_wide null terminates" {
    var buffer: [8]u16 = [_]u16{0xFFFF} ** 8;

    text.copy_wide(&buffer, "Test");

    try testing.expectEqual(@as(u16, 0), buffer[4]);
}

test "copy_wide handles empty source" {
    var buffer: [8]u16 = [_]u16{0xFFFF} ** 8;

    text.copy_wide(&buffer, "");

    try testing.expectEqual(@as(u16, 0), buffer[0]);
}

test "copy_wide_opts respects max_length" {
    var buffer: [16]u16 = undefined;

    text.copy_wide_opts(&buffer, "Hello World", .{ .max_length = 6 });

    try testing.expectEqual(@as(u16, 'H'), buffer[0]);
    try testing.expectEqual(@as(u16, 'e'), buffer[1]);
    try testing.expectEqual(@as(u16, 'l'), buffer[2]);
    try testing.expectEqual(@as(u16, 'l'), buffer[3]);
    try testing.expectEqual(@as(u16, 'o'), buffer[4]);
    try testing.expectEqual(@as(u16, 0), buffer[5]);
}

test "copy_wide_opts without null termination" {
    var buffer: [8]u16 = [_]u16{0xFFFF} ** 8;

    text.copy_wide_opts(&buffer, "Test", .{ .null_terminate = false });

    try testing.expectEqual(@as(u16, 'T'), buffer[0]);
    try testing.expectEqual(@as(u16, 'e'), buffer[1]);
    try testing.expectEqual(@as(u16, 's'), buffer[2]);
    try testing.expectEqual(@as(u16, 't'), buffer[3]);
    try testing.expectEqual(@as(u16, 0xFFFF), buffer[4]);
}

test "utf8_to_wide converts ascii" {
    var buffer: [16]u16 = undefined;

    const len = try text.utf8_to_wide(&buffer, "Hello");

    try testing.expectEqual(@as(u64, 5), len);
    try testing.expectEqual(@as(u16, 'H'), buffer[0]);
    try testing.expectEqual(@as(u16, 'o'), buffer[4]);
    try testing.expectEqual(@as(u16, 0), buffer[5]);
}

test "utf8_to_wide handles empty string" {
    var buffer: [16]u16 = [_]u16{0xFFFF} ** 16;

    const len = try text.utf8_to_wide(&buffer, "");

    try testing.expectEqual(@as(u64, 0), len);
    try testing.expectEqual(@as(u16, 0), buffer[0]);
}

test "wide_to_utf8 converts ascii" {
    const wide = [_]u16{ 'H', 'e', 'l', 'l', 'o' };
    var buffer: [16]u8 = undefined;

    const len = try text.wide_to_utf8(&buffer, &wide);

    try testing.expectEqual(@as(u64, 5), len);
    try testing.expectEqualStrings("Hello", buffer[0..5]);
}

test "wide_to_utf8 handles empty slice" {
    const wide = [_]u16{};
    var buffer: [16]u8 = [_]u8{0xFF} ** 16;

    const len = try text.wide_to_utf8(&buffer, &wide);

    try testing.expectEqual(@as(u64, 0), len);
    try testing.expectEqual(@as(u8, 0), buffer[0]);
}

test "wide_len counts characters" {
    const wide: [*:0]const u16 = &[_:0]u16{ 'H', 'e', 'l', 'l', 'o' };

    const len = text.wide_len(wide);

    try testing.expectEqual(@as(u64, 5), len);
}

test "wide_len returns zero for empty string" {
    const wide: [*:0]const u16 = &[_:0]u16{};

    const len = text.wide_len(wide);

    try testing.expectEqual(@as(u64, 0), len);
}

test "wide_slice creates slice from sentinel pointer" {
    const wide: [*:0]const u16 = &[_:0]u16{ 'T', 'e', 's', 't' };

    const slice = text.wide_slice(wide);

    try testing.expectEqual(@as(usize, 4), slice.len);
    try testing.expectEqual(@as(u16, 'T'), slice[0]);
    try testing.expectEqual(@as(u16, 't'), slice[3]);
}

test "equals returns true for matching slices" {
    try testing.expect(text.equals("hello", "hello"));
}

test "equals returns false for non-matching slices" {
    try testing.expect(!text.equals("hello", "world"));
}

test "equals returns false for different lengths" {
    try testing.expect(!text.equals("hello", "hell"));
    try testing.expect(!text.equals("hello", "helloo"));
}

test "equals_wide returns true for matching slices" {
    const a = [_]u16{ 'H', 'i' };
    const b = [_]u16{ 'H', 'i' };

    try testing.expect(text.equals_wide(&a, &b));
}

test "equals_wide returns false for non-matching slices" {
    const a = [_]u16{ 'H', 'i' };
    const b = [_]u16{ 'B', 'y' };

    try testing.expect(!text.equals_wide(&a, &b));
}

test "starts_with returns true for matching prefix" {
    try testing.expect(text.starts_with("hello world", "hello"));
}

test "starts_with returns false for non-matching prefix" {
    try testing.expect(!text.starts_with("hello world", "world"));
}

test "starts_with returns true for empty prefix" {
    try testing.expect(text.starts_with("hello", ""));
}

test "ends_with returns true for matching suffix" {
    try testing.expect(text.ends_with("hello world", "world"));
}

test "ends_with returns false for non-matching suffix" {
    try testing.expect(!text.ends_with("hello world", "hello"));
}

test "ends_with returns true for empty suffix" {
    try testing.expect(text.ends_with("hello", ""));
}

test "roundtrip utf8 to wide and back" {
    const original = "Testing 123";
    var wide: [32]u16 = undefined;
    var result: [32]u8 = undefined;

    const wide_len = try text.utf8_to_wide(&wide, original);
    const utf8_len = try text.wide_to_utf8(&result, wide[0..wide_len]);

    try testing.expectEqualStrings(original, result[0..utf8_len]);
}
