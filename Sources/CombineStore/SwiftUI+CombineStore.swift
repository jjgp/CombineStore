import SwiftUI

// MARK: - Environment

public extension View {
    func provide<State, Action>(store: Store<State, Action>) -> some View {
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

// MARK: - ComposeStore

public struct ComposeStore<State, Action, Content>: View where Content: View {
    private let content: () -> Content
    @Environment(\.store) private var environmentStore
    private let store: Store<State, Action>?

    public init<LocalState>(
        fromState: (State) -> LocalState,
        toState: (LocalState) -> State,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        store = nil
    }

    @ViewBuilder
    public var body: some View {
        Text(verbatim: "WIP")
    }
}

// MARK: - MapStore

public struct MapStore<T, State, Action, Content>: View where Content: View {
    private let content: (T) -> Content
    @Environment(\.store) private var environmentStore
    private let store: Store<State, Action>?
    private let transform: (Store<State, Action>) -> T

    public init(_ transform: @escaping (Store<State, Action>) -> T, @ViewBuilder content: @escaping (T) -> Content) {
        self.content = content
        self.store = nil
        self.transform = transform
    }

    public init(
        _ store: Store<State, Action>,
        transform: @escaping (Store<State, Action>) -> T,
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
            content(transform(environmentStore as! Store<State, Action>))
        }
    }

    typealias TrueContent = ModifiedContent<Content, _EnvironmentKeyWritingModifier<Any>>
}

// MARK: - StoreProvider

public struct StoreProvider<State, Action, Content>: View where Content: View {
    private let content: (Store<State, Action>) -> Content
    @Environment(\.store) private var environmentStore
    private let store: Store<State, Action>?

    public init(@ViewBuilder content: @escaping (Store<State, Action>) -> Content) {
        self.content = content
        store = nil
    }

    public init(_ store: Store<State, Action>, @ViewBuilder content: @escaping (Store<State, Action>) -> Content) {
        self.content = content
        self.store = store
    }

    public init(_ store: Store<State, Action>, @ViewBuilder content: @escaping () -> Content) {
        self.content = { _ in content() }
        self.store = store
    }

    @ViewBuilder
    public var body: some View {
        if store != nil {
            content(store!).provide(store: store!)
        } else {
            content(environmentStore as! Store<State, Action>)
        }
    }
}

