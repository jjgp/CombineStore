import Combine

// MARK: - Accumulator

public typealias Accumulator<State, Action> = (inout State?, Action) -> State?

// MARK: - Effect

public struct Effect<State, Action, Environment> {
    let effect: (ActionPublisher, StatePublisher, Environment) -> ActionPublisher?

    public init<P: Publisher>(
        publisher: @escaping (ActionPublisher, StatePublisher, Environment) -> P
    ) where P.Output == Action, P.Failure == Never {
        effect = { publisher($0, $1, $2).eraseToAnyPublisher() }
    }

    public init(sink: @escaping (ActionPublisher, StatePublisher, Environment) -> Void) {
        effect = {
            sink($0, $1, $2)
            return nil
        }
    }

    public typealias ActionPublisher = AnyPublisher<Action, Never>
    public typealias StatePublisher = AnyPublisher<State?, Never>
}

// MARK: - Store

public final class Store<State, Action>: ObservableObject {
    private var cancellableSet: Set<AnyCancellable> = []
    private let sender: PassthroughSubject<Action, Never>
    @Published public private(set) var state: State?

    public init<Environment>(accumulator: @escaping Accumulator<State, Action>,
                             initialState: State? = nil,
                             effects: [Effect<State, Action, Environment>] = [],
                             environment: Environment) {
        let sender = PassthroughSubject<Action, Never>()
        self.sender = sender
        state = initialState
        sender
            .scan(initialState, { state, action in
                var state = state
                return accumulator(&state, action)
            })
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

    deinit {
        print("oh boi deinit happend!")
    }
}
