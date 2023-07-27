import AppKit
import MenuBuilder

public enum Handler {
    case closure(() -> Void)
    case action(Selector)
}

private extension AnyMenuItem {
    func handler(_ handler: Handler) -> Self {
        switch handler {
        case .action(let action): return self.action(action)
        case .closure(let closure): return self.onSelect(closure)
        }
    }
}

public struct MainMenuOptions {
    public init(
        settingsHandler: Handler? = nil,
        appMenuItems: [NSMenuItem] = [],
        openHandler: Handler? = nil,
        showToggleSidebar: Bool = false,
        windowMenuItems: [NSMenuItem] = [],
        helpMenuItems: [NSMenuItem] = []
    ) {
        self.settingsHandler = settingsHandler
        self.appMenuItems = appMenuItems
        self.openHandler = openHandler
        self.showToggleSidebar = showToggleSidebar
        self.windowMenuItems = windowMenuItems
        self.helpMenuItems = helpMenuItems
    }
    public let settingsHandler: Handler?
    public let appMenuItems: [NSMenuItem]
    public let openHandler: Handler?
    public let showToggleSidebar: Bool
    public let windowMenuItems: [NSMenuItem]
    public let helpMenuItems: [NSMenuItem]
}

public func createMainMenu(options: MainMenuOptions = MainMenuOptions()) -> NSMenu {
    let mainBundle = Bundle.main
    let appName = mainBundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        mainBundle.executableURL!.lastPathComponent // For bare executables, use the filename as the app name.
    
    return NSMenu {
        MenuItem(appName).submenu {
            MenuItem("About \(appName)")
                .action(#selector(NSApplication.orderFrontStandardAboutPanel(_:)))
            options.appMenuItems
            if let settingsHandler = options.settingsHandler {
                SeparatorItem()
                MenuItem("Settings…")
                    .shortcut(",")
                    .handler(settingsHandler)
            }
            SeparatorItem()
            MenuItem("Services").submenu({ }).apply {
                NSApp.servicesMenu = $0.submenu
            }
            SeparatorItem()
            MenuItem("Hide \(appName)")
                .shortcut("h")
                .action(#selector(NSApplication.hide(_:)))
            MenuItem("Hide Others")
                .shortcut("h", holding: [.option, .command])
                .action(#selector(NSApplication.hideOtherApplications(_:)))
            MenuItem("Show All")
                .action(#selector(NSApplication.unhideAllApplications(_:)))
            SeparatorItem()
            MenuItem("Quit \(appName)")
                .shortcut("q")
                .action(#selector(NSApplication.terminate(_:)))
        }
        MenuItem("File").submenu {
            if let openHandler = options.openHandler {
                MenuItem("Open…").shortcut("o").handler(openHandler)
                MenuItem("Open Recent").submenu {
                    MenuItem("Clear Menu").action(#selector(NSDocumentController.clearRecentDocuments(_:)))
                }
                SeparatorItem()
            }
            MenuItem("Close").shortcut("w").action(#selector(NSWindow.performClose(_:)))
        }
        MenuItem("Edit").submenu {
            MenuItem("Undo").shortcut("z").action(NSSelectorFromString("undo:"))
            MenuItem("Redo").shortcut("Z").action(NSSelectorFromString("redo:"))
            SeparatorItem()
            MenuItem("Cut").shortcut("x").action(#selector(NSText.cut(_:)))
            MenuItem("Copy").shortcut("c").action(#selector(NSText.copy(_:)))
            MenuItem("Paste").shortcut("v").action(#selector(NSText.paste(_:)))
            MenuItem("Paste and Match Style")
                .shortcut("V", holding: [.option, .command])
                .action(#selector(NSTextView.pasteAsPlainText(_:)))
            MenuItem("Delete").action(#selector(NSText.delete(_:)))
            MenuItem("Select All").shortcut("a").action(#selector(NSText.selectAll(_:)))
            SeparatorItem()
            MenuItem("Find…")
                .shortcut("f")
                .action(#selector(NSTextView.performFindPanelAction(_:)))
                .tag(Int(NSTextFinder.Action.showFindInterface.rawValue))
        }

        MenuItem("View").submenu {
            if options.showToggleSidebar {
                MenuItem("Toggle Sidebar")
                    .shortcut("s", holding: [.option, .command])
                    .action(#selector(NSSplitViewController.toggleSidebar(_:)))
                SeparatorItem()
            }
            MenuItem("Toggle Full Screen")
                .shortcut("f", holding: [.control, .command])
                .action(#selector(NSWindow.toggleFullScreen(_:)))
        }
        MenuItem("Window").submenu {
            MenuItem("Minimize").shortcut("m").action(#selector(NSWindow.performMiniaturize(_:)))
            MenuItem("Zoom").action(#selector(NSWindow.performZoom(_:)))
            SeparatorItem()
            options.windowMenuItems
            SeparatorItem()
            MenuItem("Bring All to Front").action(#selector(NSApplication.arrangeInFront(_:)))
        }.apply { NSApp.windowsMenu = $0.submenu }
        MenuItem("Help").submenu {
            options.helpMenuItems
        }.apply { NSApp.helpMenu = $0.submenu }
    }
}
