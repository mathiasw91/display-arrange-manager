//
//  AppDelegate.swift
//  display-arrange-manager
//
//  Created by Mathias Widera on 30.11.21.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var popover = NSPopover.init()
    var statusBarItem: NSStatusItem?
    static var shared : AppDelegate!
    let persistenceController = PersistenceController.shared
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        let contentView = ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)

        // Set the SwiftUI's ContentView to the Popover's ContentViewController
        popover.behavior = .applicationDefined
        popover.animates = false
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: contentView)
        popover.contentViewController?.view.window?.makeKey()
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.title = "DAM"
        statusBarItem?.button?.action = #selector(AppDelegate.togglePopover(_:))
    }
    @objc func showPopover(_ sender: AnyObject?) {
        NSApp.activate(ignoringOtherApps: true)
        if let button = statusBarItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    @objc func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
    }
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
            self.popover.contentViewController?.view.window?.becomeKey()
        }
    }
    
    func applicationWillResignActive(_ notification: Notification) {
        closePopover(nil)
    }
    
}
