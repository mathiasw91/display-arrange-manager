//
//  ContentView.swift
//  display-arrange-manager
//
//  Created by Mathias Widera on 30.11.21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Arrangement.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Arrangement.name, ascending: true)]
    ) private var arrangements: FetchedResults<Arrangement>
    
    var body: some View {
        if !arrangements.isEmpty {
            List {
                ForEach(arrangements, id: \.self)  { arrangement in
                    HStack {
                        Text("\(arrangement.name!) (\(arrangement.screens!.count))")
                        Spacer()
                        Button("apply") {
                            applyArrangement(arrangement: arrangement)
                        }
                        Button(
                            action: {deleteArrangement(arrangement: arrangement)},
                            label: {Image(systemName: "minus").padding(10)}
                        ).frame(height: 16)
                    }
                }
            }.buttonStyle(BorderlessButtonStyle())
        } else {
            Text("You have no arrangements yet").padding(10)
        }
        HStack {
            Button {} label: { Image(systemName: "power")}.hidden()
            Spacer()
            Button(
                action: addArrangement,
                label: {Image(systemName: "plus")}
            ).buttonStyle(BorderlessButtonStyle())
            Spacer()
            Button(
                action: {quitApp()},
                label: {Image(systemName: "power")}
            ).buttonStyle(BorderlessButtonStyle())
        }.padding(.top, 2).padding(.trailing, 10).padding(.leading, 10).padding(.bottom, 7)
    }
    
    func addArrangement() {
        let (alert, input) = getProfilNameAlert()
        let response = alert.runModal()
        if (response != NSApplication.ModalResponse.alertFirstButtonReturn) {
            return
        }
        let arrangement = Arrangement(context: managedObjectContext)
        arrangement.name = input.stringValue
        let maxDisplays: UInt32 = 16
        var onlineDisplays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
        var displayCount: UInt32 = 0
        _ = CGGetOnlineDisplayList(maxDisplays, &onlineDisplays, &displayCount)
        for currentDisplay in onlineDisplays[0..<Int(displayCount)] {
            let bounds = CGDisplayBounds(currentDisplay)
            let screen = Screen(context: managedObjectContext)
            screen.screenid = Int32(CGDisplayModelNumber(currentDisplay))
            screen.x = Float(bounds.origin.x)
            screen.y = Float(bounds.origin.y)
            arrangement.addToScreens(screen)
        }
        PersistenceController.shared.save()
    }
    
    func getProfilNameAlert() -> (alert: NSAlert, input: NSTextField) {
        let alert = NSAlert()
        alert.messageText = "Insert Arrangement Name"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.icon = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = input
        alert.window.initialFirstResponder = input
        return (alert, input)
    }
    
    func applyArrangement(arrangement: Arrangement) {
        var configRef: CGDisplayConfigRef? = nil
        CGBeginDisplayConfiguration(&configRef)
        for case let screen as Screen in arrangement.screens! {
            let maxDisplays: UInt32 = 16
            var onlineDisplays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
            var displayCount: UInt32 = 0
            _ = CGGetOnlineDisplayList(maxDisplays, &onlineDisplays, &displayCount)
            for currentDisplay in onlineDisplays[0..<Int(displayCount)] {
                if (Int32(CGDisplayModelNumber(currentDisplay)) == screen.screenid) {
                    CGConfigureDisplayOrigin(configRef, CGDirectDisplayID(currentDisplay), Int32(screen.x), Int32(screen.y))
                }
            }
        }
        CGCompleteDisplayConfiguration(configRef, .permanently)
    }
    
    func deleteArrangement(arrangement: Arrangement) {
        managedObjectContext.delete(arrangement)
        PersistenceController.shared.save()
    }
    
    func quitApp() {
        NSApp.terminate(self)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
