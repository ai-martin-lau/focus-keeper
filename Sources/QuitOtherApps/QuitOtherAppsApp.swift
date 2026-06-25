import SwiftUI

@main
struct QuitOtherAppsApp: App {
    @StateObject private var scanner = ApplicationScanner()
    @StateObject private var whitelist = WhitelistStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scanner)
                .environmentObject(whitelist)
        }
        .windowStyle(.titleBar)
    }
}
