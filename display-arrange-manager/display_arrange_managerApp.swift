//
//  display_arrange_managerApp.swift
//  display-arrange-manager
//
//  Created by Mathias Widera on 30.11.21.
//

import SwiftUI

@main
struct display_arrange_managerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    init() {
      AppDelegate.shared = self.appDelegate
    }
    var body: some Scene {
        Settings{
            EmptyView()
        }
    }
}
