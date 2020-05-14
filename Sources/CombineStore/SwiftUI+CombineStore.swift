import SwiftUI

// MARK: - Environment

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

// MARK: - MapStore

public struct MapStore<T, S, A, Content>: View where Content: View {
    private let content: (T) -> Content
    @Environment(\.store) private var environmentStore
    private let store: Store<S, A>?
    private let transform: (Store<S, A>) -> T

    public init(_ transform: @escaping (Store<S, A>) -> T, @ViewBuilder content: @escaping (T) -> Content) {
        self.content = content
        self.store = nil
        self.transform = transform
    }

    public init(
        _ store: Store<S, A>,
        transform: @escaping (Store<S, A>) -> T,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.content = content
        self.store = store
        self.transform = transform
    }

    @ViewBuilder
    public var body: some View {
        if store != nil {
            content(transform(store!)).provide(store: store!)
        } else {
            content(transform(environmentStore as! Store<S, A>))
        }
    }

    typealias TrueContent = ModifiedContent<Content, _EnvironmentKeyWritingModifier<Any>>
}

// MARK: - StoreProvider

public struct StoreProvider<S, A, Content>: View where Content: View {
    private let content: (Store<S, A>) -> Content
    @Environment(\.store) private var environmentStore
    private let store: Store<S, A>?

    public init(@ViewBuilder content: @escaping (Store<S, A>) -> Content) {
        self.content = content
        store = nil
    }

    public init(_ store: Store<S, A>, @ViewBuilder content: @escaping (Store<S, A>) -> Content) {
        self.content = content
        self.store = store
    }

    @ViewBuilder
    public var body: some View {
        if store != nil {
            content(store!).provide(store: store!)
        } else {
            content(environmentStore as! Store<S, A>)
        }
    }
}

