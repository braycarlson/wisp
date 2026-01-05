const std = @import("std");

pub const Options = struct {
    max_length: ?u32 = null,
    null_terminate: bool = true,
};

pub fn copy_wide(buffer: anytype, source: []const u8) void {
    copy_wide_opts(buffer, source, Options{});
}

pub fn copy_wide_opts(buffer: anytype, source: []const u8, options: Options) void {
    const buffer_length: u32 = @intCast(buffer.len);
    const source_length: u32 = @intCast(source.len);
    const max_length = options.max_length orelse buffer_length;
    const space = if (options.null_terminate) max_length - 1 else max_length;
    const limit = @min(source_length, space);

    var index: u32 = 0;

    while (index < limit) : (index += 1) {
        if (index >= limit) {
            break;
        }

        if (index >= buffer_length) {
            break;
        }

        buffer[index] = source[index];
    }

    if (options.null_terminate and index < buffer_length) {
        buffer[index] = 0;
    }
}

pub fn ends_with(haystack: []const u8, suffix: []const u8) bool {
    const result = std.mem.endsWith(u8, haystack, suffix);

    return result;
}

pub fn equals(left: []const u8, right: []const u8) bool {
    const result = std.mem.eql(u8, left, right);

    return result;
}

pub fn equals_wide(left: []const u16, right: []const u16) bool {
    const result = std.mem.eql(u16, left, right);

    return result;
}

pub fn starts_with(haystack: []const u8, prefix: []const u8) bool {
    const result = std.mem.startsWith(u8, haystack, prefix);

    return result;
}

pub fn utf8_to_wide(destination: []u16, source: []const u8) !u64 {
    if (source.len == 0) {
        if (destination.len > 0) {
            destination[0] = 0;
        }

        return 0;
    }

    const length = try std.unicode.utf8ToUtf16Le(destination, source);

    if (length < destination.len) {
        destination[length] = 0;
    }

    return length;
}

pub fn wide_len(source: [*:0]const u16) u64 {
    var index: u64 = 0;

    while (source[index] != 0) : (index += 1) {
        if (index >= 65535) {
            break;
        }
    }

    return index;
}

pub fn wide_slice(source: [*:0]const u16) [:0]const u16 {
    const length = wide_len(source);
    const result = source[0..length :0];

    return result;
}

pub fn wide_to_utf8(destination: []u8, source: []const u16) !u64 {
    if (source.len == 0) {
        if (destination.len > 0) {
            destination[0] = 0;
        }

        return 0;
    }

    const length = try std.unicode.utf16LeToUtf8(destination, source);

    if (length < destination.len) {
        destination[length] = 0;
    }

    return length;
}
