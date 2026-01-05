pub const icon = @import("icon.zig");
pub const menu = @import("menu.zig");
pub const notification = @import("notification.zig");
pub const state = @import("state.zig");
pub const timer = @import("timer.zig");
pub const tray = @import("tray.zig");
pub const window = @import("window.zig");

pub const IconManager = icon.IconManager;
pub const IconSource = icon.Source;
pub const IconError = icon.Error;

pub const MenuManager = menu.MenuManager;
pub const MenuItem = menu.Item;
pub const MenuItemKind = menu.ItemKind;
pub const MenuError = menu.Error;

pub const NotificationManager = notification.NotificationManager;
pub const Notification = notification.Notification;
pub const NotificationIcon = notification.Icon;
pub const NotificationError = notification.Error;

pub const StateManager = state.StateManager;
pub const StateTransition = state.Transition;
pub const StateError = state.Error;

pub const TimerManager = timer.TimerManager;
pub const TimerHandle = timer.Handle;
pub const TimerError = timer.Error;

pub const TrayManager = tray.TrayManager;
pub const TrayConfig = tray.Config;
pub const TrayError = tray.Error;
pub const TrayBalloonIcon = tray.BalloonIcon;

pub const WindowManager = window.WindowManager;
pub const WindowConfig = window.Config;
pub const WindowError = window.Error;
