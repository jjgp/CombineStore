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
