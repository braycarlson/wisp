const ui = @import("ui/root.zig");
const win32 = @import("win32/root.zig");

const IconManager = ui.IconManager;
const MenuManager = ui.MenuManager;

pub const IconBuilder = struct {
    manager: *IconManager,

    pub fn init(manager: *IconManager) IconBuilder {
        return IconBuilder{ .manager = manager };
    }

    pub fn resource(self: IconBuilder, name: []const u8, id: u32) IconBuilder {
        self.manager.add_resource(name, id) catch {};

        return self;
    }

    pub fn system(self: IconBuilder, name: []const u8, sys: win32.IconSystem) IconBuilder {
        self.manager.add_system(name, sys) catch {};

        return self;
    }

    pub fn done(self: IconBuilder) *IconManager {
        return self.manager;
    }
};

pub const MenuBuilder = struct {
    manager: *MenuManager,

    pub fn init(manager: *MenuManager) MenuBuilder {
        return MenuBuilder{ .manager = manager };
    }

    pub fn action(self: MenuBuilder, id: u32, label: []const u8) MenuBuilder {
        self.manager.add_action(id, label) catch {};

        return self;
    }

    pub fn separator(self: MenuBuilder) MenuBuilder {
        self.manager.add_separator() catch {};

        return self;
    }

    pub fn toggle(self: MenuBuilder, id: u32, label: []const u8, initial: bool) MenuBuilder {
        self.manager.add_toggle(id, label, initial) catch {};

        return self;
    }

    pub fn radio(self: MenuBuilder, id: u32, label: []const u8, group: []const u8, initial: bool) MenuBuilder {
        self.manager.add_radio(id, label, group, initial) catch {};

        return self;
    }

    pub fn done(self: MenuBuilder) *MenuManager {
        return self.manager;
    }
};
