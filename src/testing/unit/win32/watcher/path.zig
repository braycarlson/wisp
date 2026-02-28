const std = @import("std");
const testing = std.testing;

const source = @import("wisp").win32.watcher.path;

const Path = source.Path;

test "Path.parse extracts directory and filename" {
    const path = try Path.parse("C:\\Users\\test\\file.txt");

    try testing.expectEqualStrings("C:\\Users\\test", path.get_directory());
    try testing.expectEqualStrings("file.txt", path.get_filename());
}

test "Path.parse handles simple path" {
    const path = try Path.parse("dir\\file.txt");

    try testing.expectEqualStrings("dir", path.get_directory());
    try testing.expectEqualStrings("file.txt", path.get_filename());
}

test "Path.parse returns error for empty path" {
    const result = Path.parse("");

    try testing.expectError(source.Error.InvalidPath, result);
}

test "Path.is_valid returns true for valid path" {
    const path = try Path.parse("C:\\dir\\file.txt");

    try testing.expect(path.is_valid());
}

test "Path.is_valid returns false for zero lengths" {
    var path = Path{};

    try testing.expect(!path.is_valid());

    path.directory_len = 5;

    try testing.expect(!path.is_valid());

    path.directory_len = 0;
    path.filename_len = 5;

    try testing.expect(!path.is_valid());
}

test "Path.get_directory returns stored directory" {
    const path = try Path.parse("C:\\test\\example.txt");

    try testing.expectEqualStrings("C:\\test", path.get_directory());
}

test "Path.get_filename returns stored filename" {
    const path = try Path.parse("C:\\test\\example.txt");

    try testing.expectEqualStrings("example.txt", path.get_filename());
}

test "Path handles forward slashes" {
    const path = try Path.parse("dir/subdir/file.txt");

    try testing.expect(path.is_valid());
    try testing.expectEqualStrings("file.txt", path.get_filename());
}

test "Path handles deep nesting" {
    const path = try Path.parse("C:\\a\\b\\c\\d\\e\\file.txt");

    try testing.expect(path.is_valid());
    try testing.expectEqualStrings("C:\\a\\b\\c\\d\\e", path.get_directory());
    try testing.expectEqualStrings("file.txt", path.get_filename());
}

test "Path handles filename with multiple dots" {
    const path = try Path.parse("dir\\file.name.txt");

    try testing.expectEqualStrings("file.name.txt", path.get_filename());
}

test "Path handles filename without extension" {
    const path = try Path.parse("dir\\filename");

    try testing.expectEqualStrings("filename", path.get_filename());
}
