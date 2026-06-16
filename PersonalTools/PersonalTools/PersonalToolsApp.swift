import SwiftUI

@main
struct PersonalToolsApp: App {
    @StateObject private var fastingStore = FastingStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(fastingStore)
        }
    }
}
