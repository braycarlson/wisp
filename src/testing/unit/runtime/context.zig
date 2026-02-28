const std = @import("std");
const testing = std.testing;

const source = @import("wisp").runtime.context;

const AnyContext = source.AnyContext;
const Context = source.Context;

const TestStruct = struct {
    value: u32,
    name: [16]u8,
};

const OtherStruct = struct {
    data: i64,
};

test "Context.init creates context with pointer" {
    var data = TestStruct{
        .value = 42,
        .name = [_]u8{0} ** 16,
    };

    const ctx = Context(TestStruct).init(&data);

    try testing.expectEqual(&data, ctx.ptr);
}

test "Context.get returns pointer to data" {
    var data = TestStruct{
        .value = 100,
        .name = [_]u8{0} ** 16,
    };

    const ctx = Context(TestStruct).init(&data);
    const ptr = ctx.get();

    try testing.expectEqual(@as(u32, 100), ptr.value);

    ptr.value = 200;

    try testing.expectEqual(@as(u32, 200), data.value);
}

test "AnyContext.init creates type-erased context" {
    var data = TestStruct{
        .value = 42,
        .name = [_]u8{0} ** 16,
    };

    const ctx = AnyContext.init(TestStruct, &data);

    try testing.expect(@intFromPtr(ctx.ptr) != 0);
    try testing.expect(ctx.type_id != 0);
}

test "AnyContext.cast returns pointer for matching type" {
    var data = TestStruct{
        .value = 42,
        .name = [_]u8{0} ** 16,
    };

    const ctx = AnyContext.init(TestStruct, &data);
    const result = ctx.cast(TestStruct);

    try testing.expect(result != null);
    try testing.expectEqual(@as(u32, 42), result.?.value);
}

test "AnyContext.cast returns null for mismatched type" {
    var data = TestStruct{
        .value = 42,
        .name = [_]u8{0} ** 16,
    };

    const ctx = AnyContext.init(TestStruct, &data);
    const result = ctx.cast(OtherStruct);

    try testing.expect(result == null);
}

test "AnyContext.cast allows modification through pointer" {
    var data = TestStruct{
        .value = 10,
        .name = [_]u8{0} ** 16,
    };

    const ctx = AnyContext.init(TestStruct, &data);
    const ptr = ctx.cast(TestStruct);

    try testing.expect(ptr != null);

    ptr.?.value = 99;

    try testing.expectEqual(@as(u32, 99), data.value);
}

test "AnyContext different types have different type_ids" {
    var data1 = TestStruct{
        .value = 1,
        .name = [_]u8{0} ** 16,
    };

    var data2 = OtherStruct{
        .data = 2,
    };

    const ctx1 = AnyContext.init(TestStruct, &data1);
    const ctx2 = AnyContext.init(OtherStruct, &data2);

    try testing.expect(ctx1.type_id != ctx2.type_id);
}

test "AnyContext same types have same type_id" {
    var data1 = TestStruct{
        .value = 1,
        .name = [_]u8{0} ** 16,
    };

    var data2 = TestStruct{
        .value = 2,
        .name = [_]u8{0} ** 16,
    };

    const ctx1 = AnyContext.init(TestStruct, &data1);
    const ctx2 = AnyContext.init(TestStruct, &data2);

    try testing.expectEqual(ctx1.type_id, ctx2.type_id);
}
