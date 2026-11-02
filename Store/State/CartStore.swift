import Foundation
import Observation

@Observable
final class CartStore {
    private(set) var items: [CartItem] = []

    var count: Int { items.reduce(0) { $0 + $1.quantity } }

    var total: Decimal { items.reduce(0) { $0 + $1.subtotal } }

    func quantity(of product: Product) -> Int {
        items.first { $0.product == product }?.quantity ?? 0
    }

    func add(_ product: Product) {
        if let index = items.firstIndex(where: { $0.product == product }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
    }

    func decrement(_ product: Product) {
        guard let index = items.firstIndex(where: { $0.product == product }) else { return }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            items.remove(at: index)
        }
    }

    func remove(_ product: Product) {
        items.removeAll { $0.product == product }
    }

    func clear() {
        items.removeAll()
    }
}
