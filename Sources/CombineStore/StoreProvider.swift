import SwiftUI

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

    public var body: some View {
        if store != nil {
            return ViewBuilder.buildEither(first: content(store!).provide(store: store!) as! TrueContent)
                as _ConditionalContent<TrueContent, Content>
        } else {
            return ViewBuilder.buildEither(second: content(environmentStore as! Store<S, A>))
                as _ConditionalContent<TrueContent, Content>
        }
    }

    typealias TrueContent = ModifiedContent<Content, _EnvironmentKeyWritingModifier<Any>>
}
