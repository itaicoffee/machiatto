import AppKit
import IOKit.pwr_mgt

/// Machiatto: a one-click menubar caffeine toggle.
/// Click the coffee bean to keep the Mac awake; click again to let it sleep.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var assertionID: IOPMAssertionID = 0
    private var isCaffeinated = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.action = #selector(handleClick(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        render()
    }

    func applicationWillTerminate(_ notification: Notification) {
        release()
    }

    @objc private func handleClick(_ sender: Any?) {
        if let event = NSApp.currentEvent, event.type == .rightMouseUp {
            showContextMenu()
            return
        }
        toggle()
    }

    private func toggle() {
        isCaffeinated ? release() : acquire()
        render()
    }

    private func acquire() {
        let reason = "Machiatto: user requested the Mac stay awake" as CFString
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )
        isCaffeinated = (result == kIOReturnSuccess)
        if !isCaffeinated {
            NSLog("Machiatto: failed to create power assertion (\(result))")
        }
    }

    private func release() {
        guard isCaffeinated else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0
        isCaffeinated = false
    }

    private func render() {
        guard let button = statusItem.button else { return }
        let symbol = isCaffeinated ? "cup.and.saucer.fill" : "cup.and.saucer"
        let description = isCaffeinated ? "Caffeinated: sleep prevented" : "Sleep allowed"
        if let image = NSImage(systemSymbolName: symbol, accessibilityDescription: description) {
            image.isTemplate = true
            button.image = image
            button.title = ""
        } else {
            button.image = nil
            button.title = isCaffeinated ? "☕︎" : "○"
        }
        button.toolTip = "Machiatto — \(description). Click to toggle."
        button.appearsDisabled = !isCaffeinated
    }

    private func showContextMenu() {
        let menu = NSMenu()
        let state = NSMenuItem(
            title: isCaffeinated ? "Caffeinated (no sleep)" : "Sleep allowed",
            action: nil, keyEquivalent: ""
        )
        state.isEnabled = false
        menu.addItem(state)
        menu.addItem(.separator())
        menu.addItem(withTitle: "Toggle", action: #selector(menuToggle), keyEquivalent: "")
        menu.addItem(withTitle: "Quit Machiatto", action: #selector(quit), keyEquivalent: "q")
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func menuToggle() { toggle() }
    @objc private func quit() { NSApp.terminate(nil) }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
