import SwiftUI

public extension View {
    func provide<S, A>(store: Store<S, A>) -> some View {
        environment(\.store, store)
    }
}

struct StoreKey: EnvironmentKey {
    static let defaultValue: Any = ()
}

extension EnvironmentValues {
    var store: Any {
        get { self[StoreKey.self] }
        set { self[StoreKey.self] = newValue }
    }
}
