import Cocoa
import AVFoundation

class ClickableStatusBarButton: NSStatusBarButton {
    var leftClickAction: (() -> Void)?
    var rightClickMenu: NSMenu?

    override func mouseDown(with event: NSEvent) {
        if event.type == .leftMouseDown {
            leftClickAction?()
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        if let menu = rightClickMenu {
            NSMenu.popUpContextMenu(menu, with: event, for: self)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var audioPlayer: AVAudioPlayer?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            let customButton = ClickableStatusBarButton(frame: button.bounds)
            statusItem.button?.superview?.addSubview(customButton)
            statusItem.button?.removeFromSuperview()
//            customButton.image = NSImage(systemSymbolName: "speaker.wave.2", accessibilityDescription: "lizard")
            customButton.title = "🦎"
            customButton.leftClickAction = { [weak self] in self?.playAudio() }
            customButton.rightClickMenu = constructMenu()
            customButton.target = self
        }
        
        guard let audioURL = Bundle.main.url(forResource: "lizard", withExtension: "wav") else {
            print("Audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
        } catch {
            print("Failed to setup audio: \(error)")
        }
    }

    @objc func playAudio() {
        audioPlayer?.play()
    }
    
    func constructMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(
            withTitle: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        
        return menu
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
