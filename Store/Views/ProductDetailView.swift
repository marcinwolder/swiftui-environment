import SwiftUI

/// Ekran szczegółów edytuje stan koszyka, choć nie jest jego właścicielem
/// ani potomkiem `CartView`.
struct ProductDetailView: View {
    let product: Product
    @Environment(CartStore.self) private var cart

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: product.symbol)
                .font(.system(size: 80))
                .padding(.top, 24)
            Text(product.name).font(.largeTitle.bold())
            Text(product.price, format: .currency(code: "PLN"))
                .font(.title2)
            Text(product.details)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button {
                cart.add(product)
            } label: {
                Label("Dodaj do koszyka", systemImage: "cart.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)

            if cart.quantity(of: product) > 0 {
                Text("W koszyku: \(cart.quantity(of: product))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                CartToolbarButton()
            }
        }
    }
}
