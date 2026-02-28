const std = @import("std");

const event = @import("wisp").event;
const runtime = @import("wisp").runtime;

const Bus = event.Bus;
const Kind = event.Kind;
const Response = event.Response;
const Stage = runtime.Stage;

const common = @import("common.zig");

pub const handler_max: u8 = 32;
pub const state_name_max: u8 = 32;
pub const retry_max: u8 = 10;
pub const iteration_max: u32 = 0xFFFFFFFF;
pub const operation_subscribe_threshold: u8 = 40;
pub const operation_unsubscribe_threshold: u8 = 60;
pub const operation_emit_threshold: u8 = 85;
pub const operation_clear_threshold: u8 = 95;

pub const Operation = union(enum) {
    subscribe: SubscribeData,
    unsubscribe: u8,
    emit: void,
    clear: void,
    lifecycle_transition: Stage,
    set_enabled: SetEnabledData,

    pub const SubscribeData = struct {
        priority: u8,
        has_filter: bool,
    };

    pub const SetEnabledData = struct {
        index: u8,
        enabled: bool,
    };

    pub fn apply(self: Operation, bus: *Bus) void {
        std.debug.assert(@intFromPtr(bus) != 0);

        switch (self) {
            .subscribe => |data| {
                const handler = event.Handler.init(dummy_handler);
                var h = handler;

                h.priority = data.priority;

                _ = bus.subscribe(h);
            },
            .unsubscribe => |index| {
                bus.remove(index);
            },
            .emit => {
                const test_event = event.Event.app_init();
                _ = bus.emit(&test_event);
            },
            .clear => {
                bus.clear();
            },
            .lifecycle_transition => {},
            .set_enabled => |data| {
                bus.set_enabled(data.index, data.enabled);
            },
        }
    }

    pub fn apply_to_model(self: Operation, model: *Model) void {
        std.debug.assert(@intFromPtr(model) != 0);
        std.debug.assert(model.is_valid());

        switch (self) {
            .subscribe => |data| {
                model.add_handler(data.priority, data.has_filter);
            },
            .unsubscribe => |index| {
                model.remove_handler(index);
            },
            .emit => {},
            .clear => {
                model.clear();
            },
            .lifecycle_transition => |target| {
                model.transition_lifecycle(target);
            },
            .set_enabled => |data| {
                model.set_handler_enabled(data.index, data.enabled);
            },
        }
    }

    pub fn format(self: Operation, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;

        switch (self) {
            .subscribe => |data| {
                try writer.print("subscribe(priority={d}, has_filter={any})", .{ data.priority, data.has_filter });
            },
            .unsubscribe => |index| {
                try writer.print("unsubscribe(index={d})", .{index});
            },
            .emit => {
                try writer.print("emit()", .{});
            },
            .clear => {
                try writer.print("clear()", .{});
            },
            .lifecycle_transition => |target| {
                try writer.print("lifecycle_transition(target={s})", .{@tagName(target)});
            },
            .set_enabled => |data| {
                try writer.print("set_enabled(index={d}, enabled={any})", .{ data.index, data.enabled });
            },
        }
    }
};

fn dummy_handler(_: *const event.Event, _: ?*anyopaque) Response {
    return .pass;
}

pub const HandlerState = struct {
    active: bool,
    enabled: bool,
    priority: u8,
    has_filter: bool,

    pub fn init() HandlerState {
        const result = HandlerState{
            .active = false,
            .enabled = true,
            .priority = 100,
            .has_filter = false,
        };

        return result;
    }
};

pub const Model = struct {
    handlers: [handler_max]HandlerState,
    count: u8,
    lifecycle_stage: Stage,

    pub fn init() Model {
        var result = Model{
            .handlers = undefined,
            .count = 0,
            .lifecycle_stage = .created,
        };

        var i: u8 = 0;

        while (i < handler_max) : (i += 1) {
            std.debug.assert(i < handler_max);

            result.handlers[i] = HandlerState.init();
        }

        std.debug.assert(i == handler_max);
        std.debug.assert(result.count == 0);
        std.debug.assert(result.is_valid());

        return result;
    }

    pub fn is_valid(self: *const Model) bool {
        std.debug.assert(@intFromPtr(self) != 0);

        const valid_count = self.count <= handler_max;
        const result = valid_count;

        return result;
    }

    pub fn add_handler(self: *Model, priority: u8, has_filter: bool) void {
        std.debug.assert(self.is_valid());

        if (self.count >= handler_max) {
            return;
        }

        var i: u8 = 0;

        while (i < handler_max) : (i += 1) {
            std.debug.assert(i < handler_max);

            if (!self.handlers[i].active) {
                self.handlers[i] = HandlerState{
                    .active = true,
                    .enabled = true,
                    .priority = priority,
                    .has_filter = has_filter,
                };
                self.count += 1;

                std.debug.assert(self.count <= handler_max);

                return;
            }
        }

        std.debug.assert(i == handler_max);
    }

    pub fn remove_handler(self: *Model, index: u8) void {
        std.debug.assert(self.is_valid());
        std.debug.assert(index < handler_max);

        if (self.handlers[index].active) {
            self.handlers[index].active = false;

            std.debug.assert(self.count > 0);

            self.count -= 1;
        }
    }

    pub fn set_handler_enabled(self: *Model, index: u8, enabled: bool) void {
        std.debug.assert(self.is_valid());
        std.debug.assert(index < handler_max);

        if (self.handlers[index].active) {
            self.handlers[index].enabled = enabled;
        }
    }

    pub fn clear(self: *Model) void {
        std.debug.assert(self.is_valid());

        var i: u8 = 0;

        while (i < handler_max) : (i += 1) {
            std.debug.assert(i < handler_max);

            self.handlers[i].active = false;
        }

        self.count = 0;

        std.debug.assert(i == handler_max);
        std.debug.assert(self.count == 0);
    }

    pub fn transition_lifecycle(self: *Model, target: Stage) void {
        std.debug.assert(self.is_valid());

        if (self.lifecycle_stage.can_transition_to(target)) {
            self.lifecycle_stage = target;
        }
    }

    pub fn matches(self: *const Model, bus: *const Bus) bool {
        std.debug.assert(@intFromPtr(self) != 0);
        std.debug.assert(@intFromPtr(bus) != 0);
        std.debug.assert(self.is_valid());

        if (self.count != bus.handler_count()) {
            return false;
        }

        return true;
    }

    pub fn get_active_count(self: *const Model) u8 {
        std.debug.assert(self.is_valid());

        var active: u8 = 0;
        var i: u8 = 0;

        while (i < handler_max) : (i += 1) {
            std.debug.assert(i < handler_max);

            if (self.handlers[i].active) {
                active += 1;
            }
        }

        std.debug.assert(i == handler_max);
        std.debug.assert(active == self.count);

        return active;
    }

    pub fn get_random_active_index(self: *const Model, random: *std.Random) ?u8 {
        std.debug.assert(self.is_valid());
        std.debug.assert(@intFromPtr(random) != 0);

        if (self.count == 0) {
            return null;
        }

        var indices: [handler_max]u8 = undefined;
        var found: u8 = 0;
        var i: u8 = 0;

        while (i < handler_max) : (i += 1) {
            std.debug.assert(i < handler_max);

            if (self.handlers[i].active) {
                indices[found] = i;
                found += 1;
            }
        }

        std.debug.assert(i == handler_max);

        if (found == 0) {
            return null;
        }

        const choice = random.intRangeLessThan(u8, 0, found);

        std.debug.assert(choice < found);

        const result = indices[choice];

        return result;
    }
};

pub fn generate_operation(random: *std.Random, model: *const Model) Operation {
    std.debug.assert(@intFromPtr(random) != 0);
    std.debug.assert(@intFromPtr(model) != 0);
    std.debug.assert(model.is_valid());

    const roll = random.intRangeLessThan(u8, 0, 100);

    std.debug.assert(roll < 100);

    if (roll < operation_subscribe_threshold) {
        const priority = random.intRangeAtMost(u8, 0, 255);
        const has_filter = random.intRangeLessThan(u8, 0, 2) == 1;

        return Operation{ .subscribe = .{ .priority = priority, .has_filter = has_filter } };
    } else if (roll < operation_unsubscribe_threshold) {
        if (model.get_random_active_index(random)) |index| {
            return Operation{ .unsubscribe = index };
        }

        return Operation{ .subscribe = .{ .priority = 100, .has_filter = false } };
    } else if (roll < operation_emit_threshold) {
        return Operation{ .emit = {} };
    } else if (roll < operation_clear_threshold) {
        const index = random.intRangeLessThan(u8, 0, handler_max);
        const enabled = random.intRangeLessThan(u8, 0, 2) == 1;

        return Operation{ .set_enabled = .{ .index = index, .enabled = enabled } };
    } else {
        return Operation{ .clear = {} };
    }
}

const testing = std.testing;

test "Model init" {
    const model = Model.init();

    try testing.expectEqual(@as(u8, 0), model.count);
    try testing.expect(model.is_valid());
}

test "Model add_handler" {
    var model = Model.init();

    model.add_handler(50, false);

    try testing.expectEqual(@as(u8, 1), model.count);
    try testing.expect(model.handlers[0].active);
    try testing.expectEqual(@as(u8, 50), model.handlers[0].priority);
}

test "Model remove_handler" {
    var model = Model.init();

    model.add_handler(50, false);
    model.remove_handler(0);

    try testing.expectEqual(@as(u8, 0), model.count);
    try testing.expect(!model.handlers[0].active);
}

test "Model clear" {
    var model = Model.init();

    model.add_handler(50, false);
    model.add_handler(75, false);
    model.clear();

    try testing.expectEqual(@as(u8, 0), model.count);
}

test "Model capacity limit" {
    var model = Model.init();
    var i: u8 = 0;

    while (i < handler_max) : (i += 1) {
        std.debug.assert(i < handler_max);

        model.add_handler(i, false);
    }

    std.debug.assert(i == handler_max);

    try testing.expectEqual(handler_max, model.count);

    model.add_handler(99, false);

    try testing.expectEqual(handler_max, model.count);
}

test "generate_operation produces valid operations" {
    var prng = std.Random.DefaultPrng.init(42);
    var random = prng.random();
    const model = Model.init();
    var i: u32 = 0;

    while (i < 100) : (i += 1) {
        std.debug.assert(i < 100);

        const op = generate_operation(&random, &model);

        _ = op;
    }

    std.debug.assert(i == 100);
}
