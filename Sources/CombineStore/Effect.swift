import Combine

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
    public typealias StatePublisher = AnyPublisher<State, Never>
}
