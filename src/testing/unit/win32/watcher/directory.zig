const std = @import("std");
const testing = std.testing;

const w32 = @import("win32").everything;
const wisp = @import("wisp");

const source = wisp.win32.watcher.directory;
const path_max = wisp.win32.watcher.path_max;

const Directory = source.Directory;

test "Directory.is_valid returns false for invalid handle" {
    const directory = Directory{
        .handle = w32.INVALID_HANDLE_VALUE,
    };

    try testing.expect(!directory.is_valid());
}

test "Directory.open returns error for empty path" {
    const result = Directory.open("");

    try testing.expectError(source.Error.InvalidPath, result);
}

test "Directory.open returns error for path exceeding max" {
    var long_path: [path_max + 1]u8 = undefined;
    var index: u32 = 0;

    while (index < path_max + 1) : (index += 1) {
        std.debug.assert(index < path_max + 1);

        long_path[index] = 'a';
    }

    const result = Directory.open(&long_path);

    try testing.expectError(source.Error.InvalidPath, result);
}

test "path_max constant value" {
    try testing.expectEqual(@as(u32, 512), path_max);
}
