import Cocoa

@main
final class MainApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory) // hide dock icon (also LSUIElement in Info.plist)
        app.run()
    }
}
