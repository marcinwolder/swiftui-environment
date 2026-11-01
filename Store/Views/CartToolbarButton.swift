import SwiftUI

/// Ikona koszyka z badge w pasku nawigacji.
/// Widok nie zna `CartView`. Czyta tylko `CartStore` z Environment.
struct CartToolbarButton: View {
    @Environment(CartStore.self) private var cart

    var body: some View {
        NavigationLink(value: CartRoute()) {
            Image(systemName: "cart")
                .overlay(alignment: .topTrailing) {
                    if cart.count > 0 {
                        Text("\(cart.count)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(.red, in: Capsule())
                            .offset(x: 10, y: -10)
                    }
                }
        }
        .accessibilityLabel("Koszyk, \(cart.count) sztuk")
    }
}
