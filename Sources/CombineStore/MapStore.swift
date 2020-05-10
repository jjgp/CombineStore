import SwiftUI

public struct StoreProvider<S, A, Content>: View where Content: View {
    private let content: (Store<S, A>) -> Content
    @Environment(\.store) private var store

    public init(@ViewBuilder content: @escaping (Store<S, A>) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(store as! Store<S, A>)
    }
}

public struct MapStore<T, S, A, Content>: View where Content: View {
    private let content: (T) -> Content
    @Environment(\.store) private var store
    private let transform: (Store<S, A>) -> T

    public init(_ transform: @escaping (Store<S, A>) -> T, @ViewBuilder content: @escaping (T) -> Content) {
        self.content = content
        self.transform = transform
    }

    public var body: some View {
        content(transform(store as! Store<S, A>))
    }
}
