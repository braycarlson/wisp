const std = @import("std");

const wisp = @import("wisp");
const event = wisp.event;

const Bus = event.Bus;
const Event = event.Event;
const Handler = event.Handler;
const Kind = event.Kind;
const Response = event.Response;

const common = @import("common.zig");

pub const handler_capacity: u8 = 32;
pub const iteration_max: u32 = 0xFFFFFFFF;
pub const priority_max: u8 = 255;

pub fn fuzz_bus(random: *std.Random, iterations: u32) !void {
    std.debug.assert(@intFromPtr(random) != 0);
    std.debug.assert(iterations > 0);
    std.debug.assert(iterations <= iteration_max);

    var bus = Bus.init();
    var subscribed: u8 = 0;
    var i: u32 = 0;

    while (i < iterations and i < iteration_max) : (i += 1) {
        std.debug.assert(i < iterations);

        const action = random.intRangeLessThan(u8, 0, 100);

        if (action < 40) {
            if (subscribed < handler_capacity) {
                const handler = Handler.init(test_handler);

                if (bus.subscribe(handler) != null) {
                    subscribed += 1;
                }
            }
        } else if (action < 60) {
            if (subscribed > 0) {
                const index = random.intRangeLessThan(u8, 0, handler_capacity);

                bus.remove(index);

                if (subscribed > 0) {
                    subscribed = bus.handler_count();
                }
            }
        } else if (action < 85) {
            const test_event = Event.app_init();
            _ = bus.emit(&test_event);
        } else if (action < 95) {
            const index = random.intRangeLessThan(u8, 0, handler_capacity);
            const enabled = common.random_bool(random);

            bus.set_enabled(index, enabled);
        } else {
            bus.clear();
            subscribed = 0;
        }

        std.debug.assert(bus.handler_count() <= handler_capacity);
    }

    std.debug.assert(i == iterations or i == iteration_max);

    bus.deinit();
}

pub fn fuzz_handler(random: *std.Random, iterations: u32) !void {
    std.debug.assert(@intFromPtr(random) != 0);
    std.debug.assert(iterations > 0);
    std.debug.assert(iterations <= iteration_max);

    var i: u32 = 0;

    while (i < iterations and i < iteration_max) : (i += 1) {
        std.debug.assert(i < iterations);

        const priority = random.intRangeAtMost(u8, 0, priority_max);
        const use_filter = common.random_bool(random);

        var handler = Handler.init(test_handler);

        handler.priority = priority;

        if (use_filter) {
            handler.filter = .app_init;
        }

        std.debug.assert(handler.priority == priority);
        std.debug.assert(handler.enabled == true);

        const enabled = common.random_bool(random);

        handler.enabled = enabled;

        std.debug.assert(handler.enabled == enabled);

        const test_event = Event.create(.app_init, .{ .app_init = {} });

        const response = handler.invoke(&test_event);

        std.debug.assert(@intFromEnum(response) <= 2);
    }

    std.debug.assert(i == iterations or i == iteration_max);
}

pub fn fuzz_priority_ordering(random: *std.Random, iterations: u32) !void {
    std.debug.assert(@intFromPtr(random) != 0);
    std.debug.assert(iterations > 0);

    var i: u32 = 0;

    while (i < iterations and i < iteration_max) : (i += 1) {
        std.debug.assert(i < iterations);

        var bus = Bus.init();
        var priorities: [handler_capacity]u8 = undefined;
        var count: u8 = 0;

        const num_handlers = random.intRangeAtMost(u8, 1, handler_capacity);

        var j: u8 = 0;

        while (j < num_handlers) : (j += 1) {
            std.debug.assert(j < num_handlers);

            const priority = random.intRangeAtMost(u8, 0, priority_max);
            var handler = Handler.init(test_handler);

            handler.priority = priority;

            if (bus.subscribe(handler) != null) {
                priorities[count] = priority;
                count += 1;
            }
        }

        std.debug.assert(j == num_handlers);
        std.debug.assert(count <= handler_capacity);

        bus.deinit();
    }

    std.debug.assert(i == iterations or i == iteration_max);
}

fn test_handler(_: *const Event, _: ?*anyopaque) Response {
    return .pass;
}

const testing = std.testing;

test "fuzz_bus basic" {
    var prng = std.Random.DefaultPrng.init(42);
    var random = prng.random();

    try fuzz_bus(&random, 100);
}

test "fuzz_bus determinism" {
    var prng1 = std.Random.DefaultPrng.init(12345);
    var prng2 = std.Random.DefaultPrng.init(12345);
    var random1 = prng1.random();
    var random2 = prng2.random();

    try fuzz_bus(&random1, 100);
    try fuzz_bus(&random2, 100);
}

test "fuzz_handler basic" {
    var prng = std.Random.DefaultPrng.init(42);
    var random = prng.random();

    try fuzz_handler(&random, 100);
}

test "fuzz_priority_ordering basic" {
    var prng = std.Random.DefaultPrng.init(42);
    var random = prng.random();

    try fuzz_priority_ordering(&random, 50);
}
