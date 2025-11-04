//
//  DataObserver.swift
//  iOS
//
//  Created by Anton Cherkasov on 04.11.2025.
//

actor DataObserver<T> {

	// MARK: - Internal State

	private var continuation: AsyncStream<T>.Continuation?

	private var currentData: T

	// MARK: - Public

	lazy var stream: AsyncStream<T> = {
		AsyncStream { [weak self] continuation in
			Task {
				await self?.set(continuation: continuation)
			}
		}
	}()

	// MARK: - Initialization

	init(initialData: T) {
		self.currentData = initialData
	}

	deinit {
		self.continuation = nil
	}
}

// MARK: - Public Interface
extension DataObserver {

	func sendData(_ data: T) {
		self.currentData = data
		continuation?.yield(data)
	}

	func lastValue() -> T {
		return currentData
	}
}

// MARK: - Helpers
private extension DataObserver {

	func set(continuation: AsyncStream<T>.Continuation?) {
		self.continuation = continuation
	}
}
