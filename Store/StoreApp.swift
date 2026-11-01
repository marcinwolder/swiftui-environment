import SwiftUI

@main
struct StoreApp: App {
    // Stan koszyka stoi w korzeniu. Widoki dostają go przez Environment,
    // więc nie ma przekazywania przez parametry (prop drilling).
    @State private var cart = CartStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(cart)
        }
    }
}
