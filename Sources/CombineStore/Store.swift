import Combine

public final class Effect<S, A> {
    private var cancellable: Set<AnyCancellable>!
    private(set) var effect: Effect!

    public init(_ sink: @escaping (AnyPublisher<A, Never>, AnyPublisher<S, Never>, inout Set<AnyCancellable>) -> Void) {
        effect = { [weak self] dispatch, state in
            guard let self = self else {
                return nil
            }
            self.cancellable = []
            sink(dispatch, state, &self.cancellable)
            return nil
        }
    }

    public init(_ publisher: @escaping Effect) {
        effect = publisher
    }

    public init<P: Publisher>(
        _ publisher: @escaping (AnyPublisher<A, Never>, AnyPublisher<S, Never>) -> P
    ) where P.Output == A, P.Failure == Never {
        effect = { publisher($0, $1).eraseToAnyPublisher() }
    }

    public typealias Effect = (AnyPublisher<A, Never>, AnyPublisher<S, Never>) -> AnyPublisher<A, Never>?
}

public final class Store<S, A>: ObservableObject {
    private var cancellableSet: Set<AnyCancellable> = []
    private let dispatch: PassthroughSubject<A, Never>
    private let effects: [Effect<S, A>]
    @Published public private(set) var state: S

    public init(accumulator: @escaping Accumulator,
                initialState: S,
                effects: [Effect<S, A>] = []) {
        let dispatch = PassthroughSubject<A, Never>()
        self.dispatch = dispatch
        state = initialState
        self.effects = effects
        dispatch
            .scan(initialState, accumulator)
            .assign(to: \.state, on: self)
            .store(in: &cancellableSet)
        // Note, this could potentially be dangerous as it leads to a circular publisher. In RxJS and RxSwift, a
        // circular publisher may need to be scheduled on another queue. An Effect that simply returns `dispatch` will
        // result in infinite recursion.
        Publishers.MergeMany(
            effects.compactMap({
                $0.effect(dispatch.eraseToAnyPublisher(), $state.eraseToAnyPublisher())
            })
        )
            .sink(receiveValue: dispatch.send)
            .store(in: &cancellableSet)
    }

    public func send(_ action: A) {
        dispatch.send(action)
    }

    public typealias Accumulator = (S, A) -> S
}
