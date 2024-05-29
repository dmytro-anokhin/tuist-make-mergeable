import SwiftUI
import Framework

@main
struct MyAppApp: App {
    var body: some Scene {
        WindowGroup {
            Text(Framework.version)
        }
    }
}
