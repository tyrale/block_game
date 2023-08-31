import Cocoa

// App
let nsapp = NSApplication.shared
NSApp.setActivationPolicy(.regular)

// Menu bar
let menubar = NSMenu()
let appMenuItem = NSMenuItem()
menubar.addItem(appMenuItem)
NSApp.mainMenu = menubar
let appMenu = NSMenu()

let appName = ProcessInfo.processInfo.processName
let quitTitle = "Quit " + appName
let quitMenuItem = NSMenuItem(
  title: quitTitle,
  action: #selector(NSApplication.terminate), keyEquivalent: "q"
)
appMenu.addItem(quitMenuItem)
appMenuItem.submenu = appMenu

let gameConfig = GameConfig()

// Window
let window = NSWindow(
  contentRect: .init(x: 0, y: 0, width: gameConfig.winWidth, height: gameConfig.winHeight),
  styleMask: [.titled],
  backing: .buffered,
  defer: false
)
window.title = appName
window.makeKeyAndOrderFront(nil)

NSApp.activate(ignoringOtherApps: true)

// Game
let game = initGame(config: gameConfig)
let gameCanvasView = GameCanvas(frame: window.frame, game: game)
window.contentView = gameCanvasView
gameCanvasView.setupTimers()
gameCanvasView.becomeFirstResponder()

NSApp.run()
