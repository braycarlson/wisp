const std = @import("std");
const testing = std.testing;

const wisp = @import("wisp");

const Bus = wisp.event.Bus;
const Service = wisp.runtime.service.Service;

test "Service.init creates unbound service" {
    var bus = Bus.init();
    defer bus.deinit();

    const service = Service.init(&bus);

    try testing.expect(service.hwnd == null);
    try testing.expect(!service.is_bound());
}

test "Service.is_bound returns false when hwnd is null" {
    var bus = Bus.init();
    defer bus.deinit();

    const service = Service.init(&bus);

    try testing.expect(!service.is_bound());
}

test "Service stores bus reference" {
    var bus = Bus.init();
    defer bus.deinit();

    const service = Service.init(&bus);

    try testing.expectEqual(&bus, service.bus);
}
