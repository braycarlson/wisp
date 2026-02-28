const std = @import("std");
const testing = std.testing;

const source = @import("wisp").win32.watcher.waiter;

const WaitResult = source.WaitResult;

test "WaitResult enum values" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(WaitResult.complete));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(WaitResult.failed));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(WaitResult.stopped));
}

test "WaitResult.is_valid returns true for all variants" {
    try testing.expect(WaitResult.complete.is_valid());
    try testing.expect(WaitResult.failed.is_valid());
    try testing.expect(WaitResult.stopped.is_valid());
}

test "wait_max constant value" {
    try testing.expectEqual(@as(u8, 2), source.wait_max);
}
