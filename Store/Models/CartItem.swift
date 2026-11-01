import Foundation

struct CartItem: Identifiable, Equatable {
    let product: Product
    var quantity: Int

    var id: Product.ID { product.id }
    var subtotal: Decimal { product.price * Decimal(quantity) }
}
