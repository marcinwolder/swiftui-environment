import Foundation
import Observation

/// Jedyne źródło prawdy o koszyku.
///
/// Właścicielem instancji jest korzeń aplikacji (`StoreApp`), ale żaden widok
/// nie dostaje jej przez parametry. Każdy widok bierze ją sam przez
/// `@Environment(CartStore.self)`. To odpowiednik `Context.Provider` z Reacta.
///
/// `@Observable` śledzi, które właściwości widok czyta w `body`.
/// Widok odświeża się tylko wtedy, gdy zmieni się właściwość, którą czyta.
@Observable
final class CartStore {
    /// Tylko store zmienia tablicę. Widoki wywołują metody poniżej.
    private(set) var items: [CartItem] = []

    /// Liczba sztuk we wszystkich pozycjach. Czyta ją badge w pasku nawigacji.
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
