import SwiftUI

@main
struct StoreApp: App {
    @State private var cart = CartStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(cart)
        }
    }
}
