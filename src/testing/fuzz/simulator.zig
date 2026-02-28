const std = @import("std");

const event = @import("wisp").event;

const Bus = event.Bus;

const model_mod = @import("model.zig");

const Model = model_mod.Model;
const Operation = model_mod.Operation;

pub const trace_capacity: u32 = 4096;
pub const step_max: u32 = 0xFFFFFFFF;

pub const Failure = struct {
    step: u32,
    invariant: []const u8,
    operation: Operation,
    seed: u64,

    pub fn format(self: Failure, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;

        std.debug.assert(self.step > 0 or self.step == 0);
        std.debug.assert(self.invariant.len > 0);

        try writer.print("Failure at step {d}: invariant '{s}' violated by ", .{ self.step, self.invariant });
        try self.operation.format("", .{}, writer);
        try writer.print(" (seed={d})", .{self.seed});
    }
};

pub const Trace = struct {
    operations: [trace_capacity]Operation,
    len: u32,

    pub fn init() Trace {
        const result = Trace{
            .operations = undefined,
            .len = 0,
        };

        std.debug.assert(result.len == 0);

        return result;
    }

    pub fn push(self: *Trace, op: Operation) void {
        std.debug.assert(@intFromPtr(self) != 0);
        std.debug.assert(self.len <= trace_capacity);

        if (self.len >= trace_capacity) {
            return;
        }

        std.debug.assert(self.len < trace_capacity);

        self.operations[self.len] = op;
        self.len += 1;

        std.debug.assert(self.len <= trace_capacity);
    }

    pub fn clear(self: *Trace) void {
        std.debug.assert(@intFromPtr(self) != 0);

        self.len = 0;

        std.debug.assert(self.len == 0);
    }

    pub fn get(self: *const Trace, index: u32) ?Operation {
        std.debug.assert(@intFromPtr(self) != 0);

        if (index >= self.len) {
            return null;
        }

        std.debug.assert(index < self.len);

        const result = self.operations[index];

        return result;
    }
};

pub const Simulator = struct {
    bus: Bus,
    model: Model,
    prng: std.Random.DefaultPrng,
    seed: u64,
    step: u32,
    trace: Trace,

    pub fn init(seed: u64) Simulator {
        const result = Simulator{
            .bus = Bus.init(),
            .model = Model.init(),
            .prng = std.Random.DefaultPrng.init(seed),
            .seed = seed,
            .step = 0,
            .trace = Trace.init(),
        };

        std.debug.assert(result.step == 0);
        std.debug.assert(result.trace.len == 0);
        std.debug.assert(result.model.is_valid());

        return result;
    }

    pub fn reseed(self: *Simulator, seed: u64) void {
        std.debug.assert(@intFromPtr(self) != 0);

        self.bus.clear();
        self.model = Model.init();
        self.prng = std.Random.DefaultPrng.init(seed);
        self.seed = seed;
        self.step = 0;
        self.trace.clear();

        std.debug.assert(self.step == 0);
        std.debug.assert(self.trace.len == 0);
        std.debug.assert(self.model.count == 0);
    }

    pub fn run(self: *Simulator, steps: u32) ?Failure {
        std.debug.assert(@intFromPtr(self) != 0);
        std.debug.assert(steps > 0);
        std.debug.assert(self.model.is_valid());

        var random = self.prng.random();
        var operations: [trace_capacity]Operation = undefined;
        var i: u32 = 0;

        while (i < steps and i < trace_capacity) : (i += 1) {
            std.debug.assert(i < steps);
            std.debug.assert(i < trace_capacity);

            operations[i] = model_mod.generate_operation(&random, &self.model);
        }

        std.debug.assert(i == steps or i == trace_capacity);

        const count = @min(steps, trace_capacity);

        std.debug.assert(count <= trace_capacity);

        var j: u32 = 0;

        while (j < count and j < step_max) : (j += 1) {
            std.debug.assert(j < count);

            const op = operations[j];

            self.trace.push(op);

            op.apply(&self.bus);
            op.apply_to_model(&self.model);

            self.step = j + 1;

            if (!self.model.matches(&self.bus)) {
                return Failure{
                    .step = self.step,
                    .invariant = "model_mismatch",
                    .operation = op,
                    .seed = self.seed,
                };
            }
        }

        std.debug.assert(j == count or j == step_max);

        return null;
    }
};

const testing = std.testing;

test "Simulator basic" {
    var sim = Simulator.init(42);

    const failure = sim.run(1000);

    try testing.expect(failure == null);
}

test "Simulator deterministic" {
    var sim1 = Simulator.init(12345);
    var sim2 = Simulator.init(12345);

    _ = sim1.run(100);
    _ = sim2.run(100);

    try testing.expect(sim1.model.matches(&sim2.bus));
}

test "Simulator reseed" {
    var sim = Simulator.init(42);

    _ = sim.run(50);

    sim.reseed(42);

    try testing.expectEqual(@as(u32, 0), sim.step);
    try testing.expectEqual(@as(u32, 0), sim.trace.len);
}

test "Trace basic" {
    var trace = Trace.init();

    try testing.expectEqual(@as(u32, 0), trace.len);

    trace.push(Operation{ .clear = {} });

    try testing.expectEqual(@as(u32, 1), trace.len);

    const op = trace.get(0);

    try testing.expect(op != null);
}

test "Trace capacity" {
    var trace = Trace.init();
    var i: u32 = 0;

    while (i < trace_capacity) : (i += 1) {
        std.debug.assert(i < trace_capacity);

        trace.push(Operation{ .clear = {} });
    }

    std.debug.assert(i == trace_capacity);

    try testing.expectEqual(trace_capacity, trace.len);

    trace.push(Operation{ .clear = {} });

    try testing.expectEqual(trace_capacity, trace.len);
}
