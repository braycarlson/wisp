const std = @import("std");
const testing = std.testing;

const source = @import("wisp").ui.menu;

const Item = source.Item;
const ItemKind = source.ItemKind;
const MenuManager = source.MenuManager;

test "Item.action creates action item" {
    const item = Item.action(1, "Test");

    try testing.expectEqual(@as(u32, 1), item.id);
    try testing.expectEqual(ItemKind.action, item.kind);
    try testing.expectEqualStrings("Test", item.get_label());
    try testing.expect(item.enabled);
    try testing.expect(item.visible);
    try testing.expect(!item.checked);
}

test "Item.toggle creates toggle item" {
    const item = Item.toggle(2, "Toggle", true);

    try testing.expectEqual(@as(u32, 2), item.id);
    try testing.expectEqual(ItemKind.toggle, item.kind);
    try testing.expectEqualStrings("Toggle", item.get_label());
    try testing.expect(item.checked);
}

test "Item.toggle creates unchecked toggle" {
    const item = Item.toggle(3, "Toggle", false);

    try testing.expect(!item.checked);
}

test "Item.radio creates radio item" {
    const item = Item.radio(4, "Option", "group1", true);

    try testing.expectEqual(@as(u32, 4), item.id);
    try testing.expectEqual(ItemKind.radio, item.kind);
    try testing.expectEqualStrings("Option", item.get_label());
    try testing.expect(item.checked);

    const group = item.get_group();

    try testing.expect(group != null);
    try testing.expectEqualStrings("group1", group.?);
}

test "Item.separator creates separator item" {
    const item = Item.separator();

    try testing.expectEqual(ItemKind.separator, item.kind);
}

test "Item.set_label updates label" {
    var item = Item.action(1, "Old");

    item.set_label("New Label");

    try testing.expectEqualStrings("New Label", item.get_label());
}

test "Item.set_label ignores empty label" {
    var item = Item.action(1, "Original");

    item.set_label("");

    try testing.expectEqualStrings("Original", item.get_label());
}

test "Item.set_group updates group" {
    var item = Item.radio(1, "Option", "old", false);

    item.set_group("newgroup");

    const group = item.get_group();

    try testing.expect(group != null);
    try testing.expectEqualStrings("newgroup", group.?);
}

test "Item.is_in_group returns true for matching group" {
    const item = Item.radio(1, "Option", "mygroup", false);

    try testing.expect(item.is_in_group("mygroup"));
}

test "Item.is_in_group returns false for non-matching group" {
    const item = Item.radio(1, "Option", "mygroup", false);

    try testing.expect(!item.is_in_group("other"));
}

test "Item.is_in_group returns false for different length" {
    const item = Item.radio(1, "Option", "mygroup", false);

    try testing.expect(!item.is_in_group("my"));
    try testing.expect(!item.is_in_group("mygroupx"));
}

test "MenuManager.init creates empty manager" {
    const manager = MenuManager.init();

    try testing.expect(manager.is_empty());
    try testing.expectEqual(@as(u8, 0), manager.count);
    try testing.expect(manager.dirty);
}

test "MenuManager.add adds item" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add(Item.action(1, "Test"));

    try testing.expect(!manager.is_empty());
    try testing.expectEqual(@as(u8, 1), manager.count);
}

test "MenuManager.add returns error at capacity" {
    var manager = MenuManager.init();
    defer manager.deinit();

    var index: u8 = 0;

    while (index < source.item_max) : (index += 1) {
        std.debug.assert(index < source.item_max);

        try manager.add(Item.action(index, "Item"));
    }

    const result = manager.add(Item.action(255, "Overflow"));

    try testing.expectError(source.Error.CapacityExceeded, result);
}

test "MenuManager.add_action adds action item" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_action(1, "Action");

    const item = manager.get_item(1);

    try testing.expect(item != null);
    try testing.expectEqual(ItemKind.action, item.?.kind);
}

test "MenuManager.add_toggle adds toggle item" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_toggle(1, "Toggle", true);

    const item = manager.get_item(1);

    try testing.expect(item != null);
    try testing.expectEqual(ItemKind.toggle, item.?.kind);
    try testing.expect(item.?.checked);
}

test "MenuManager.add_radio adds radio item and selects in group" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_radio(1, "Option 1", "group", true);
    try manager.add_radio(2, "Option 2", "group", false);
    try manager.add_radio(3, "Option 3", "group", false);

    try testing.expect(manager.is_checked(1));
    try testing.expect(!manager.is_checked(2));
    try testing.expect(!manager.is_checked(3));
}

test "MenuManager.add_separator adds separator" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_separator();

    try testing.expectEqual(@as(u8, 1), manager.count);
}

test "MenuManager.get_item returns item by id" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_action(42, "Test");

    const item = manager.get_item(42);

    try testing.expect(item != null);
    try testing.expectEqual(@as(u32, 42), item.?.id);
}

test "MenuManager.get_item returns null for missing id" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_action(1, "Test");

    const item = manager.get_item(999);

    try testing.expect(item == null);
}

test "MenuManager.is_checked returns correct state" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_toggle(1, "Checked", true);
    try manager.add_toggle(2, "Unchecked", false);

    try testing.expect(manager.is_checked(1));
    try testing.expect(!manager.is_checked(2));
}

test "MenuManager.set_checked updates item state" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_toggle(1, "Toggle", false);

    try testing.expect(!manager.is_checked(1));

    try manager.set_checked(1, true);

    try testing.expect(manager.is_checked(1));
}

test "MenuManager.set_checked returns error for missing id" {
    var manager = MenuManager.init();
    defer manager.deinit();

    const result = manager.set_checked(999, true);

    try testing.expectError(source.Error.NotFound, result);
}

test "MenuManager.set_checked on radio updates group" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_radio(1, "Option 1", "group", true);
    try manager.add_radio(2, "Option 2", "group", false);

    try testing.expect(manager.is_checked(1));
    try testing.expect(!manager.is_checked(2));

    try manager.set_checked(2, true);

    try testing.expect(!manager.is_checked(1));
    try testing.expect(manager.is_checked(2));
}

test "MenuManager.set_enabled updates item state" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_action(1, "Action");

    try manager.set_enabled(1, false);

    const item = manager.get_item(1);

    try testing.expect(item != null);
    try testing.expect(!item.?.enabled);
}

test "MenuManager.set_enabled returns error for missing id" {
    var manager = MenuManager.init();
    defer manager.deinit();

    const result = manager.set_enabled(999, false);

    try testing.expectError(source.Error.NotFound, result);
}

test "MenuManager.set_label updates item label" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_action(1, "Old");

    try manager.set_label(1, "New");

    const item = manager.get_item(1);

    try testing.expect(item != null);
    try testing.expectEqualStrings("New", item.?.get_label());
}

test "MenuManager.set_visible updates item visibility" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_action(1, "Action");

    try manager.set_visible(1, false);

    const item = manager.get_item(1);

    try testing.expect(item != null);
    try testing.expect(!item.?.visible);
}

test "MenuManager.toggle_item toggles toggle item" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_toggle(1, "Toggle", false);

    const result1 = try manager.toggle_item(1);

    try testing.expect(result1);
    try testing.expect(manager.is_checked(1));

    const result2 = try manager.toggle_item(1);

    try testing.expect(!result2);
    try testing.expect(!manager.is_checked(1));
}

test "MenuManager.toggle_item selects radio in group" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_radio(1, "Option 1", "group", true);
    try manager.add_radio(2, "Option 2", "group", false);

    _ = try manager.toggle_item(2);

    try testing.expect(!manager.is_checked(1));
    try testing.expect(manager.is_checked(2));
}

test "MenuManager.get_radio_selection returns selected radio id" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_radio(1, "Option 1", "group", false);
    try manager.add_radio(2, "Option 2", "group", true);
    try manager.add_radio(3, "Option 3", "group", false);

    const selection = manager.get_radio_selection("group");

    try testing.expect(selection != null);
    try testing.expectEqual(@as(u32, 2), selection.?);
}

test "MenuManager.get_radio_selection returns null for no selection" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_radio(1, "Option 1", "group", false);
    try manager.add_radio(2, "Option 2", "group", false);

    const selection = manager.get_radio_selection("group");

    try testing.expect(selection == null);
}

test "MenuManager.handle_command returns adjusted id" {
    var manager = MenuManager.init();
    defer manager.deinit();

    const result = manager.handle_command(source.id_offset + 42);

    try testing.expect(result != null);
    try testing.expectEqual(@as(u32, 42), result.?);
}

test "MenuManager.handle_command returns null for invalid id" {
    var manager = MenuManager.init();
    defer manager.deinit();

    const result = manager.handle_command(50);

    try testing.expect(result == null);
}

test "MenuManager.clear removes all items" {
    var manager = MenuManager.init();
    defer manager.deinit();

    try manager.add_action(1, "Action 1");
    try manager.add_action(2, "Action 2");
    try manager.add_action(3, "Action 3");

    try testing.expectEqual(@as(u8, 3), manager.count);

    manager.clear();

    try testing.expect(manager.is_empty());
    try testing.expectEqual(@as(u8, 0), manager.count);
}

test "MenuManager.mark_dirty sets dirty flag" {
    var manager = MenuManager.init();
    defer manager.deinit();

    manager.dirty = false;
    manager.mark_dirty();

    try testing.expect(manager.dirty);
}
