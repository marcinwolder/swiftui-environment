import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            ProductListView()
                .navigationTitle("Sklep")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        CartToolbarButton()
                    }
                }
                .navigationDestination(for: Product.self) { product in
                    ProductDetailView(product: product)
                }
                .navigationDestination(for: CartRoute.self) { _ in
                    CartView()
                }
        }
    }
}

/// Znacznik trasy do ekranu koszyka.
struct CartRoute: Hashable {}

#Preview {
    RootView().environment(CartStore())
}
