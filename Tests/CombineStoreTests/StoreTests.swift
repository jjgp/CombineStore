import Combine
import XCTest
@testable import CombineStore

final class StoreTests: XCTestCase {
    func testInitialState() {
        let sut = makeSut()
        let spy = PublisherSpy(sut.$state)
        XCTAssertEqual(spy.values, [0])
    }

    func testActionsUpdateState() {
        let sut = makeSut()
        let spy = PublisherSpy(sut.$state)
        sut.send(.decrement)
        let anotherSpy = PublisherSpy(sut.$state)
        sut.send(.increment)
        XCTAssertEqual(spy.values, [0, -1, 0])
        XCTAssertEqual(anotherSpy.values, [-1, 0])
    }

    func testEffect() {
        let effect = Effect<Int, Action, Environment> { send, _, _ in
            send
                .filter { $0 == .increment }
                .map { _ in Action.decrement }
        }
        let store = makeSut(effects: [effect])
        let spy = PublisherSpy(store.$state)
        store.send(.increment)
        XCTAssertEqual(spy.values, [0, 1, 0])
    }

    func testPingPong() {
        let pingEffect = Effect<Int, Action, Environment> { send, _, _ in
            send
                .filter { $0 == .increment }
                .map { _ in Action.decrement }
                .delay(for: .milliseconds(100), scheduler: RunLoop.main, options: .none)
        }
        let pongEffect = Effect<Int, Action, Environment> { send, _, _ in
            send
                .filter { $0 == .decrement }
                .map { _ in Action.increment }
                .delay(for: .milliseconds(100), scheduler: RunLoop.main, options: .none)
        }
        let waitForExpectationEffect = Effect<Int, Action, Environment> { _, state, environment in
            state
                .sink(receiveValue: { _ in
                    // The environment is being retained here
                    environment.count += 1
                    if environment.count == 5 {
                        environment.expectation.fulfill()
                    }
                })
                .store(in: &environment.subscriptionBag)
        }

        let environment = Environment()
        environment.expectation = expectation(description: "waiting for at least 5 ping pongs")
        let store = makeSut(effects: [pingEffect, pongEffect, waitForExpectationEffect], environment: environment)
        let spy = PublisherSpy(store.$state)
        store.send(.increment)
        wait(for: [environment.expectation], timeout: 10)
        XCTAssertEqual(spy.values, [0, 1, 0, 1, 0])
    }

    func testScope() {
        
    }
}

// MARK: - Test Helpers

private enum Action: String {
    case increment
    case decrement
}

private func accumulator(state: inout Int?, action: Action) -> Int? {
    guard let state = state else {
        return nil
    }

    switch action {
    case .increment:
        return state + 1
    case .decrement:
        return state - 1
    }
}

private class Environment {
    var count = 0
    var expectation: XCTestExpectation!
    var subscriptionBag = Set<AnyCancellable>()
}

private func makeSut(initialState: Int = 0,
                     effects: [Effect<Int, Action, Environment>] = [],
                     environment: Environment = Environment()) -> Store<Int, Action> {
    return Store(
        accumulator: accumulator(state:action:),
        initialState: initialState,
        effects: effects,
        environment: environment
    )
}

private class PublisherSpy<P: Publisher> {
    private var cancellable: AnyCancellable!
    private(set) var failure: P.Failure?
    private(set) var isFinished = false
    private(set) var values: [P.Output] = []

    init(_ publisher: P) {
        cancellable = publisher.sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isFinished = false
                case let .failure(error):
                    self?.failure = error
                }
            },
            receiveValue: { [weak self] value in
                self?.values.append(value)
            }
        )
    }
}
