const std = @import("std");

const w32 = @import("win32").everything;

const event = @import("../event/root.zig");

const Bus = event.Bus;

pub const Service = struct {
    bus: *Bus,
    hwnd: ?w32.HWND,
    instance: w32.HINSTANCE,

    pub fn init(event_bus: *Bus) Service {
        std.debug.assert(@intFromPtr(event_bus) != 0);

        const result = Service{
            .bus = event_bus,
            .hwnd = null,
            .instance = undefined,
        };

        std.debug.assert(result.hwnd == null);

        return result;
    }

    pub fn bind_window(self: *Service, hwnd: w32.HWND, instance: w32.HINSTANCE) void {
        std.debug.assert(@intFromPtr(self) != 0);
        std.debug.assert(@intFromPtr(hwnd) != 0);
        std.debug.assert(@intFromPtr(instance) != 0);

        self.hwnd = hwnd;
        self.instance = instance;

        std.debug.assert(self.hwnd != null);
    }

    pub fn is_bound(self: *const Service) bool {
        std.debug.assert(@intFromPtr(self) != 0);

        const result = self.hwnd != null;

        return result;
    }
};
