import Cocoa
import SystemConfiguration

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var currentIP: String = "--"
    private var copyFeedbackTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(handleStatusItemClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        }
        refreshIP()

        // Optional: periodic refresh (e.g., every 30s)
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.refreshIP()
        }
    }

    @objc private func handleStatusItemClick(_ sender: Any?) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            showMenu()
        } else {
            copyCurrentIP()
        }
    }

    private func showMenu() {
        let menu = NSMenu()
        let titleItem = NSMenuItem(title: "IP: \(currentIP)", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "复制当前 IP", action: #selector(copyAction), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "刷新", action: #selector(refreshAction), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quitAction), keyEquivalent: "q"))

        menu.autoenablesItems = false
        statusItem.menu = menu
        statusItem.button?.performClick(nil) // show menu
        statusItem.menu = nil
    }

    @objc private func copyAction() { copyCurrentIP() }
    @objc private func refreshAction() { refreshIP() }
    @objc private func quitAction() { NSApp.terminate(nil) }

    private func refreshIP() {
        currentIP = Self.primaryIPv4() ?? Self.primaryIPv6() ?? "--"
        statusItem.button?.title = currentIP
        statusItem.button?.toolTip = "点击复制 IP，右键更多操作"
    }

    private func copyCurrentIP() {
        guard currentIP != "--" else { return }
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(currentIP, forType: .string)
        showCopiedFeedback()
    }

    private func showCopiedFeedback() {
        copyFeedbackTimer?.invalidate()
        let original = currentIP
        statusItem.button?.title = "已复制"
        copyFeedbackTimer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: false) { [weak self] _ in
            self?.statusItem.button?.title = original
        }
    }

    // MARK: - IP Helpers
    private static func primaryIPv4() -> String? {
        return firstAddress(preferInterfaces: ["en", "bridge", "utun"], family: AF_INET)
    }

    private static func primaryIPv6() -> String? {
        return firstAddress(preferInterfaces: ["en", "bridge", "utun"], family: AF_INET6)
    }

    private static func firstAddress(preferInterfaces: [String], family: Int32) -> String? {
        var ifaddrPtr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddrPtr) == 0, let firstAddr = ifaddrPtr else { return nil }
        defer { freeifaddrs(ifaddrPtr) }

        var fallback: String?
        var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let ifa = ptr?.pointee {
            ptr = ifa.ifa_next
            guard let sa = ifa.ifa_addr, sa.pointee.sa_family == UInt8(family) else { continue }
            let flags = Int32(ifa.ifa_flags)
            if (flags & IFF_UP) == 0 || (flags & IFF_LOOPBACK) != 0 { continue }
            let name = String(cString: ifa.ifa_name)

            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            var addr = sa.pointee
            let res = getnameinfo(&addr, socklen_t(sa.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
            guard res == 0 else { continue }
            let ip = String(cString: hostname)

            // Prefer specific interfaces (e.g., en0/en1) when available
            if preferInterfaces.contains(where: { name.hasPrefix($0) }) {
                return ip
            }
            if fallback == nil { fallback = ip }
        }
        return fallback
    }
}
