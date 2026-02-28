const std = @import("std");
const testing = std.testing;

const source = @import("wisp").win32.watcher.signal;

const Signal = source.Signal;

test "Signal.is_valid returns true for valid handle" {
    const signal = Signal{
        .handle = @ptrFromInt(0x12345678),
    };

    try testing.expect(signal.is_valid());
}
