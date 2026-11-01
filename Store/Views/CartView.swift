import SwiftUI

struct CartView: View {
    @Environment(CartStore.self) private var cart

    var body: some View {
        Group {
            if cart.items.isEmpty {
                ContentUnavailableView("Koszyk jest pusty", systemImage: "cart")
            } else {
                List {
                    ForEach(cart.items) { item in
                        HStack {
                            Image(systemName: item.product.symbol)
                                .frame(width: 32)
                            VStack(alignment: .leading) {
                                Text(item.product.name)
                                Text(item.subtotal, format: .currency(code: "PLN"))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Stepper(
                                "\(item.quantity)",
                                onIncrement: { cart.add(item.product) },
                                onDecrement: { cart.decrement(item.product) }
                            )
                            .fixedSize()
                        }
                    }
                    .onDelete { offsets in
                        offsets.map { cart.items[$0].product }.forEach(cart.remove)
                    }

                    HStack {
                        Text("Razem").font(.headline)
                        Spacer()
                        Text(cart.total, format: .currency(code: "PLN"))
                            .font(.headline)
                    }
                }
            }
        }
        .navigationTitle("Koszyk")
        .toolbar {
            if !cart.items.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button("Wyczyść", role: .destructive) { cart.clear() }
                }
            }
        }
    }
}
