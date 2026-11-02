import SwiftUI

struct ProductListView: View {
    @Environment(CartStore.self) private var cart

    var body: some View {
        List(Product.catalog) { product in
            NavigationLink(value: product) {
                HStack {
                    Image(systemName: product.symbol)
                        .font(.title2)
                        .frame(width: 40)
                    VStack(alignment: .leading) {
                        Text(product.name).font(.headline)
                        Text(product.price, format: .currency(code: "PLN"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        cart.add(product)
                    } label: {
                        Image(systemName: "cart.badge.plus")
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }
}
