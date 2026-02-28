pub fn Context(comptime T: type) type {
    return struct {
        ptr: *T,

        const Self = @This();

        pub fn init(ptr: *T) Self {
            return Self{ .ptr = ptr };
        }

        pub fn get(self: Self) *T {
            return self.ptr;
        }
    };
}

pub const AnyContext = struct {
    ptr: *anyopaque,
    type_id: usize,

    pub fn init(comptime T: type, ptr: *T) AnyContext {
        return AnyContext{
            .ptr = @ptrCast(ptr),
            .type_id = type_hash(T),
        };
    }

    pub fn cast(self: AnyContext, comptime T: type) ?*T {
        if (self.type_id != type_hash(T)) {
            return null;
        }

        return @ptrCast(@alignCast(self.ptr));
    }

    fn type_hash(comptime T: type) usize {
        return @intFromPtr(@typeName(T).ptr);
    }
};
