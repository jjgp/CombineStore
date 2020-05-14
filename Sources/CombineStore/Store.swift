import Combine

public final class Store<State, Action>: ObservableObject {
    private var cancellableSet: Set<AnyCancellable> = []
    private let sender: PassthroughSubject<Action, Never>
    @Published public private(set) var state: State

    public init<Environment>(accumulator: @escaping Accumulator,
                             initialState: State,
                             effects: [Effect<State, Action, Environment>] = [],
                             environment: Environment) {
        let sender = PassthroughSubject<Action, Never>()
        self.sender = sender
        state = initialState
        sender
            .scan(initialState, accumulator)
            .assign(to: \.state, on: self)
            .store(in: &cancellableSet)
        // Note, this could potentially be dangerous as it leads to a circular publisher. In RxJS and RxSwift, a
        // circular publisher may need to be scheduled on another queue. An Effect that simply returns `dispatch` will
        // result in infinite recursion.
        Publishers.MergeMany(
            effects.compactMap({
                $0.effect(sender.eraseToAnyPublisher(), $state.eraseToAnyPublisher(), environment)
            })
        )
            .sink(receiveValue: sender.send)
            .store(in: &cancellableSet)
    }

    public func send(_ action: Action) {
        sender.send(action)
    }

    public typealias Accumulator = (State, Action) -> State
}
