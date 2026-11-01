import Foundation

struct Product: Identifiable, Hashable {
    let id: Int
    let name: String
    let symbol: String      // SF Symbol zamiast zdjęcia
    let price: Decimal
    let details: String

    static let catalog: [Product] = [
        Product(id: 1, name: "Słuchawki", symbol: "headphones", price: 299, details: "Bezprzewodowe słuchawki z redukcją szumów."),
        Product(id: 2, name: "Zegarek", symbol: "applewatch", price: 899, details: "Zegarek sportowy z GPS i pomiarem tętna."),
        Product(id: 3, name: "Aparat", symbol: "camera", price: 2499, details: "Kompaktowy aparat do podróży."),
        Product(id: 4, name: "Klawiatura", symbol: "keyboard", price: 349, details: "Mechaniczna klawiatura w układzie ISO."),
        Product(id: 5, name: "Głośnik", symbol: "hifispeaker", price: 449, details: "Przenośny głośnik odporny na wodę."),
        Product(id: 6, name: "Monitor", symbol: "display", price: 1299, details: "Monitor 27 cali, matryca IPS."),
    ]
}
