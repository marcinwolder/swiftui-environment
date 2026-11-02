# Współdzielony stan w SwiftUI (`@Environment` i `@Observable`)

> [!NOTE]
> Projekt to mały sklep w SwiftUI, w którym trzy ekrany (lista, szczegóły, koszyk) czytają i zmieniają **ten sam koszyk**. Żaden z nich nie dostaje go przez parametr.

Wymagania: Xcode 16 lub nowszy, iOS 17 lub nowszy (`@Observable` i `@Environment(Typ.self)` zaczynają się w iOS 17, a makro `@Entry` w Xcode 16).

W odniesieniu do React'a: `Environment` to odpowiednik `Context`. Modyfikator `.environment(x)` odpowiada `Provider`, a `@Environment` odpowiada `useContext`.

## 1. Po co jest `Environment`?

### Problem - przekazywanie przez parametry

Ekrany sklepu stoją daleko od siebie w drzewie widoków. Bez `Environment` koszyk trzeba przekazać przez każdy widok pośredni.

```swift
RootView(cart: cart)
    └── ProductListView(cart: cart)
        └── ProductDetailView(cart: cart)
            └── CartToolbarButton(cart: cart)
```

Co jest nie tak z takim podejściem?
1. **Prop drilling.** Widoki pośrednie przekazują coś, czego same nie używają.
2. **Kruche zmiany.** Nowy ekran wymaga dopisania parametru w całym łańcuchu.
3. **Trudniejsze testy i podglądy.** Każdy widok potrzebuje ręcznie zbudowanego koszyka.

### Rozwiązanie - `Environment` $\rightarrow$ dane przypięte do drzewa widoków

**`Environment`** to dane przypięte do węzła drzewa widoków. Widzą je wszyscy potomkowie tego węzła. Widok bierze je sam, jedną linią.

```swift
struct CartToolbarButton: View {
    @Environment(CartStore.self) private var cart   // bez parametru w init

    var body: some View { Text("\(cart.count)") }
}
```

### Mapa projektu

```
Store/
├── StoreApp.swift              właściciel stanu, wstawia go do Environment
├── State/CartStore.swift       @Observable, jedyne źródło prawdy o koszyku
├── Models/
│   ├── Product.swift           produkt i katalog
│   └── CartItem.swift          produkt + ilość
└── Views/
    ├── RootView.swift          NavigationStack i trasy
    ├── ProductListView.swift   dodaje produkty
    ├── ProductDetailView.swift dodaje produkty, pokazuje ilość
    ├── CartView.swift          zmienia ilości, czyści
    └── CartToolbarButton.swift ikona z badge, tylko czyta
```

> [!NOTE]
> `Environment` to **drzewo widoków**, nie zmienna globalna.
>
> Widok spoza poddrzewa nie zobaczy obiektu. Obiekt nie jest też singletonem.

---
## 2. Gdzie żyje stan

Za stan odpowiadają dwa różne miejsca.

| Co                          | Gdzie                        | Kto tym zarządza                     |
| --------------------------- | ---------------------------- | ------------------------------------ |
| Instancja `CartStore`       | `@State` w `StoreApp`        | Właściciel, trzyma obiekt przy życiu |
| Referencja do tej instancji | `Environment` drzewa widoków | SwiftUI, przekazuje ją w dół         |

```swift
@main
struct StoreApp: App {
    @State private var cart = CartStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(cart)
        }
    }
}
```

Powód użycia `@State`: struktura `App` jest tworzona wielokrotnie. Bez `@State` powstawałby nowy `CartStore`, a koszyk by się zerował. `@State` zachowuje jedną instancję przez cały czas życia aplikacji.

Zasięg zależy od miejsca wstawienia:

```swift
RootView()
    .environment(cart)     // widzą: RootView i wszyscy potomkowie
```

> [!TIP]
> Obiekt wstawia się jak najwyżej, ale nie wyżej niż potrzeba.
>
> Wszystko poniżej tego węzła go dostanie. Wszystko obok niego nie dostanie.

---
## 3. Dodawanie obiektu do `Environment`

### 3.1 Trzy kroki

1. Oznaczenie klasy makrem `@Observable`.
2. Utworzenie instancji w korzeniu i trzymanie jej w `@State`.
3. Wstawienie jej modyfikatorem `.environment(_:)`.

```swift
@Observable
final class CartStore {                          // (1)
    private(set) var items: [CartItem] = []
}

@State private var cart = CartStore()            // (2)

RootView().environment(cart)                     // (3)
```

### 3.2 Obiekt czy wartość?

| Co się wstawia               | Wstawianie                       | Odczyt                         |
| ---------------------------- | -------------------------------- | ------------------------------ |
| Obiekt ze stanem i logiką    | `.environment(obiekt)`           | `@Environment(Typ.self) var x` |
| Mała wartość (flaga, format) | `.environment(\.klucz, wartość)` | `@Environment(\.klucz) var x`  |

Dla małej wartości definiuje się klucz. Makro `@Observable` nie jest do tego potrzebne.

```swift
extension EnvironmentValues {
    @Entry var currencyCode = "PLN"
}

ContentView().environment(\.currencyCode, "EUR")

@Environment(\.currencyCode) private var currencyCode
```

---
## 4. Czytanie obiektu

Wystarczy jedna linia w widoku.

```swift
@Environment(CartStore.self) private var cart
```

Widok nie ma parametru w inicjalizatorze. `RootView` nie zna `CartStore`, a jego potomek `CartToolbarButton` go czyta.

| Widok               | Co robi ze store                                                  |
| ------------------- | ----------------------------------------------------------------- |
| `ProductListView`   | `cart.add(product)`                                               |
| `ProductDetailView` | `cart.add(product)`, `cart.quantity(of:)`                         |
| `CartView`          | `cart.items`, `cart.total`, `add`, `decrement`, `remove`, `clear` |
| `CartToolbarButton` | `cart.count` (tylko czyta)                                        |

`ProductDetailView` zmienia koszyk, choć nie jest jego właścicielem i nie jest potomkiem `CartView`. `Environment` łączy widoki po położeniu w drzewie, a nie po relacji ekranów.

---
## 5. Edycja stanu

### 5.1 Przez metody store

Widok nie zmienia danych bezpośrednio. Widok **wywołuje metodę store**.

```swift
@Observable
final class CartStore {
    private(set) var items: [CartItem] = []

    func add(_ product: Product) { ... }
    func decrement(_ product: Product) { ... }
    func remove(_ product: Product) { ... }
    func clear() { ... }
}
```

`private(set)` blokuje zapis spoza klasy:

```swift
cart.items.append(...)   // błąd kompilacji
cart.add(product)        // OK
```

Cała logika (łączenie tych samych produktów, usuwanie przy ilości zero) jest w jednym miejscu. Nowa reguła powstaje raz, a wszystkie ekrany ją dostają.

### 5.2 `Binding` do pola obiektu

`@Environment` sam nie daje `$`. Do tego służy `@Bindable`.

```swift
struct NoteView: View {
    @Environment(CartStore.self) private var cart

    var body: some View {
        @Bindable var cart = cart
        TextField("Notatka", text: $cart.note)
    }
}
```

> [!WARNING]
> Tego w repozytorium go nie ma. Ale da się tak zrobić.

### 5.3 Podmiana obiektu w poddrzewie

Ten sam modyfikator w środku drzewa nadpisuje wartość dla potomków.

```swift
SomeView().environment(CartStore())   // SomeView widzi inny koszyk
```

Reszta aplikacji dalej widzi oryginał. Tak działają podglądy i testy widoków:

```swift
#Preview {
    RootView().environment(CartStore())
}
```

---
## 6. Skąd się bierze odświeżanie

`@Observable` zapisuje, które właściwości widok **przeczytał w `body`**. Gdy jedna z nich się zmieni, SwiftUI przelicza tylko ten widok.

| Widok               | Co czyta w `body`    | Kiedy się odświeża             |
| ------------------- | -------------------- | ------------------------------ |
| `CartToolbarButton` | `cart.count`         | zmieni się liczba sztuk        |
| `ProductDetailView` | `cart.quantity(of:)` | zmieni się ilość tego produktu |
| `ProductListView`   | nic (tylko w akcji)  | nigdy z powodu koszyka         |

Nie są potrzebne `@Published`, `objectWillChange` ani `@ObservedObject`. To starszy sposób, oparty na `ObservableObject`.

> [!NOTE]
> Zależności są liczone **w czasie działania**.
>
> Widok, który nie czyta właściwości, nie jest odświeżany, gdy ta właściwość się zmienia.

---
## 7. Pułapki

### 7.1 Brak obiektu w `Environment`

Jeśli widok czyta `@Environment(CartStore.self)`, a nikt wyżej go nie wstawił, aplikacja **zawiesza się w czasie działania**. Kompilator tego nie wykryje.

| Objaw                      | Naprawa                                        |
| -------------------------- | ---------------------------------------------- |
| crash przy otwarciu ekranu | dodanie `.environment(...)` wyżej              |
| crash w `#Preview`         | dodanie `.environment(CartStore())` w podglądzie |

### 7.2 Nawigacja i miejsce wstawienia

Widok docelowy z `navigationDestination` dostaje `Environment` z miejsca, w którym stoi `NavigationStack`. Dlatego w tym projekcie `.environment(cart)` jest nad `RootView`, czyli nad stosem.

### 7.3 Zbyt szeroki store

Jeden duży store czytany wszędzie jest wygodny. W dużej aplikacji lepiej podzielić go na mniejsze (`CartStore`, `UserStore`, `SettingsStore`). Każdy dostaje własne `.environment(...)`.

### 7.4 Logika w widoku

Gdy widok liczy sumy albo łączy pozycje, logika powinna trafić do store. W projekcie robią to `count`, `total` i `quantity(of:)`.

---
## 8. Ciekawostki dla dociekliwych

### 8.1 `Environment` szuka po typie

`@Environment(CartStore.self)` znajduje obiekt po **typie**. Gdy wstawione są dwa obiekty tego samego typu na różnych poziomach, wygrywa najbliższy węzeł nad widokiem. Dwóch różnych instancji tego samego typu na tym samym poziomie nie da się rozróżnić.

### 8.2 Obiekt i wartość to ten sam mechanizm

Różni je tylko klucz. Dla obiektu kluczem jest jego typ, a dla wartości `KeyPath` do `EnvironmentValues`.

### 8.3 Historia

Przed iOS 17 służyły do tego `ObservableObject`, `@Published` i `@EnvironmentObject`. Nowy model z `@Observable` jest prostszy i odświeża widoki dokładniej.

---
## Podsumowanie
- `Environment` to dane przypięte do **drzewa widoków**, a nie zmienna globalna.
- Właściciel trzyma obiekt w `@State` i wstawia go przez `.environment(obiekt)`.
- Widok czyta go przez `@Environment(Typ.self)`, bez parametrów.
- Dane zmienia się **przez metody store**, a `private(set)` pilnuje tej zasady.
- `@Observable` odświeża tylko widoki, które **przeczytały** zmienioną właściwość.
- Brak obiektu w `Environment` to crash w czasie działania, a nie błąd kompilacji.

## Szybka ściąga

| Cel                                   | Zapis                                  |
| ------------------------------------- | -------------------------------------- |
| Utworzenie stanu współdzielonego      | `@Observable final class X { ... }`    |
| Trzymanie go przy życiu               | `@State private var x = X()` w `App`   |
| Udostępnienie potomkom                | `.environment(x)`                      |
| Odczyt w widoku                       | `@Environment(X.self) private var x`   |
| Zmiana danych                         | `x.metoda()`                           |
| `Binding` do pola                     | `@Bindable var x = x`, potem `$x.pole` |
| Podmiana w poddrzewie lub podglądzie  | `.environment(X())`                    |
| Przekazanie małej wartości            | `@Entry` w `EnvironmentValues`         |

## Uruchomienie
1. Otwarcie `Store.xcodeproj` w Xcode.
2. Wybór symulatora z iOS 17 lub nowszym.
3. Uruchomienie przez `Cmd+R`.

## Źródła
- Apple: *Environment* (developer.apple.com/documentation/swiftui/environment)
- Apple: *Observation* (developer.apple.com/documentation/observation)
- Apple: *Managing model data in your app* (developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
