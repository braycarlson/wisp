const std = @import("std");
const testing = std.testing;

const source = @import("wisp").runtime.lifecycle;

const Lifecycle = source.Lifecycle;
const Stage = source.Stage;

test "Stage.can_transition_to allows created to configured" {
    try testing.expect(Stage.created.can_transition_to(.configured));
}

test "Stage.can_transition_to allows configured to running" {
    try testing.expect(Stage.configured.can_transition_to(.running));
}

test "Stage.can_transition_to allows running to stopping" {
    try testing.expect(Stage.running.can_transition_to(.stopping));
}

test "Stage.can_transition_to allows stopping to stopped" {
    try testing.expect(Stage.stopping.can_transition_to(.stopped));
}

test "Stage.can_transition_to disallows invalid transitions from created" {
    try testing.expect(!Stage.created.can_transition_to(.created));
    try testing.expect(!Stage.created.can_transition_to(.running));
    try testing.expect(!Stage.created.can_transition_to(.stopped));
    try testing.expect(!Stage.created.can_transition_to(.stopping));
}

test "Stage.can_transition_to disallows invalid transitions from configured" {
    try testing.expect(!Stage.configured.can_transition_to(.created));
    try testing.expect(!Stage.configured.can_transition_to(.configured));
    try testing.expect(!Stage.configured.can_transition_to(.stopped));
    try testing.expect(!Stage.configured.can_transition_to(.stopping));
}

test "Stage.can_transition_to disallows invalid transitions from running" {
    try testing.expect(!Stage.running.can_transition_to(.created));
    try testing.expect(!Stage.running.can_transition_to(.configured));
    try testing.expect(!Stage.running.can_transition_to(.running));
    try testing.expect(!Stage.running.can_transition_to(.stopped));
}

test "Stage.can_transition_to disallows all transitions from stopped" {
    try testing.expect(!Stage.stopped.can_transition_to(.created));
    try testing.expect(!Stage.stopped.can_transition_to(.configured));
    try testing.expect(!Stage.stopped.can_transition_to(.running));
    try testing.expect(!Stage.stopped.can_transition_to(.stopped));
    try testing.expect(!Stage.stopped.can_transition_to(.stopping));
}

test "Stage.can_transition_to disallows invalid transitions from stopping" {
    try testing.expect(!Stage.stopping.can_transition_to(.created));
    try testing.expect(!Stage.stopping.can_transition_to(.configured));
    try testing.expect(!Stage.stopping.can_transition_to(.running));
    try testing.expect(!Stage.stopping.can_transition_to(.stopping));
}

test "Lifecycle.init starts in created stage" {
    const lifecycle = Lifecycle.init();

    try testing.expectEqual(Stage.created, lifecycle.stage);
}

test "Lifecycle.is_configured returns correct state" {
    var lifecycle = Lifecycle.init();

    try testing.expect(!lifecycle.is_configured());

    _ = lifecycle.transition(.configured);

    try testing.expect(lifecycle.is_configured());
}

test "Lifecycle.is_running returns correct state" {
    var lifecycle = Lifecycle.init();

    try testing.expect(!lifecycle.is_running());

    _ = lifecycle.transition(.configured);
    _ = lifecycle.transition(.running);

    try testing.expect(lifecycle.is_running());
}

test "Lifecycle.is_stopped returns correct state" {
    var lifecycle = Lifecycle.init();

    try testing.expect(!lifecycle.is_stopped());

    _ = lifecycle.transition(.configured);
    _ = lifecycle.transition(.running);
    _ = lifecycle.transition(.stopping);
    _ = lifecycle.transition(.stopped);

    try testing.expect(lifecycle.is_stopped());
}

test "Lifecycle.transition succeeds for valid transitions" {
    var lifecycle = Lifecycle.init();

    try testing.expect(lifecycle.transition(.configured));
    try testing.expectEqual(Stage.configured, lifecycle.stage);

    try testing.expect(lifecycle.transition(.running));
    try testing.expectEqual(Stage.running, lifecycle.stage);

    try testing.expect(lifecycle.transition(.stopping));
    try testing.expectEqual(Stage.stopping, lifecycle.stage);

    try testing.expect(lifecycle.transition(.stopped));
    try testing.expectEqual(Stage.stopped, lifecycle.stage);
}

test "Lifecycle.transition fails for invalid transitions" {
    var lifecycle = Lifecycle.init();

    try testing.expect(!lifecycle.transition(.running));
    try testing.expectEqual(Stage.created, lifecycle.stage);

    try testing.expect(!lifecycle.transition(.stopped));
    try testing.expectEqual(Stage.created, lifecycle.stage);
}

test "Lifecycle.transition returns false and preserves state on failure" {
    var lifecycle = Lifecycle.init();

    _ = lifecycle.transition(.configured);

    try testing.expect(!lifecycle.transition(.stopped));
    try testing.expectEqual(Stage.configured, lifecycle.stage);
}

test "Lifecycle full valid transition sequence" {
    var lifecycle = Lifecycle.init();

    try testing.expectEqual(Stage.created, lifecycle.stage);
    try testing.expect(!lifecycle.is_configured());
    try testing.expect(!lifecycle.is_running());
    try testing.expect(!lifecycle.is_stopped());

    try testing.expect(lifecycle.transition(.configured));
    try testing.expect(lifecycle.is_configured());

    try testing.expect(lifecycle.transition(.running));
    try testing.expect(lifecycle.is_running());

    try testing.expect(lifecycle.transition(.stopping));
    try testing.expect(!lifecycle.is_running());

    try testing.expect(lifecycle.transition(.stopped));
    try testing.expect(lifecycle.is_stopped());
}
