const std = @import("std");
const testing = std.testing;

const source = @import("wisp").win32.watcher.processor;

test "iteration_max constant value" {
    try testing.expectEqual(@as(u32, 64), source.iteration_max);
}

test "size_buffer constant value" {
    try testing.expectEqual(@as(u32, 4096), source.size_buffer);
}

test "Callback type is function pointer" {
    const callback_info = @typeInfo(source.Callback);

    try testing.expect(callback_info == .pointer);
}
