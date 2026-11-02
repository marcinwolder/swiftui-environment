import SwiftUI

struct CartToolbarButton: View {
    @Environment(CartStore.self) private var cart

    var body: some View {
        NavigationLink(value: CartRoute()) {
            HStack(spacing: -6) {
                Image(systemName: "cart")
                badge.offset(y: -8)
            }
            .transaction { $0.animation = nil }
        }
        .accessibilityLabel("Koszyk, \(cart.count) sztuk")
    }

    @ViewBuilder
    private var badge: some View {
        if cart.count > 0 {
            Text(cart.count > 99 ? "99+" : "\(cart.count)")
                .font(.caption2.bold().monospacedDigit())
                .foregroundStyle(Color.white)
                .padding(.horizontal, 5)
                .padding(.vertical, 1)
                .frame(minWidth: 16)
                .background(Capsule().fill(Color.red))
                .fixedSize()
                .accessibilityHidden(true)
        }
    }
}
