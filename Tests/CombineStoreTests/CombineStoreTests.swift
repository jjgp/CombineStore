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
        let effect = Effect<Int, Action> { dispatch, _ in
            dispatch
                .filter { $0 == .increment }
                .map { _ in Action.decrement }
        }
        let store = makeSut(effects: [effect])
        let spy = PublisherSpy(store.$state)
        store.send(.increment)
        XCTAssertEqual(spy.values, [0, 1, 0])
    }

    func testPingPong() {
        let pingEffect = Effect<Int, Action> { dispatch, _ in
            dispatch
                .filter { $0 == .increment }
                .map { _ in Action.decrement }
                .delay(for: .milliseconds(100), scheduler: RunLoop.main, options: .none)
        }
        let pongEffect = Effect<Int, Action> { dispatch, _ in
            dispatch
                .filter { $0 == .decrement }
                .map { _ in Action.increment }
                .delay(for: .milliseconds(100), scheduler: RunLoop.main, options: .none)
        }

        let expect = expectation(description: "waiting for at least 5 ping pongs")
        var count = 0
        let waitForExpectationEffect = Effect<Int, Action> { _, state, bag in
            state
                .sink(receiveValue: {
                    _ = $0
                    count += 1
                    if count == 5 {
                        expect.fulfill()
                    }
                })
            .store(in: &bag)
        }

        let store = makeSut(effects: [pingEffect, pongEffect, waitForExpectationEffect])
        let spy = PublisherSpy(store.$state)
        store.send(.increment)
        wait(for: [expect], timeout: 10)
        XCTAssertEqual(spy.values, [0, 1, 0, 1, 0])
    }
}

// MARK: - Test Helpers

private enum Action: String {
    case increment
    case decrement
}

private func accumulator(state: Int, action: Action) -> Int {
    switch action {
    case .increment:
        return state + 1
    case .decrement:
        return state - 1
    }
}

private func makeSut(initialState: Int = 0, effects: [Effect<Int, Action>] = []) -> Store<Int, Action> {
    return Store(
        accumulator: accumulator(state:action:),
        initialState: initialState,
        effects: effects
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
