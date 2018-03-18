//
//  GenericStoreTest.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 18/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import XCTest
@testable import HMReactiveRedux

public struct GenericState<V> {
  public let value: V

  public init(_ value: V) {
    self.value = value
  }
}

public final class GenericStoreTest: XCTestCase {
  fileprivate var genericStore: GenericDispatchStoreWrapper<GenericState<Int>>!

  override public func setUp() {
    super.setUp()
    continueAfterFailure = true
    let initialState = GenericState(0)
    let queue = DispatchQueue.global(qos: .userInteractive)
    genericStore = GenericDispatchStore.createInstance(initialState, reduce, queue)
  }

  fileprivate func reduce(_ state: GenericState<Int>,
                          _ action: ReduxActionType) -> GenericState<Int> {
    let action = action as! Action
    let newValue = action.updateFn()(state.value)
    return GenericState(newValue)
  }

  public func test_dispatchGenericBasedAction_shouldUpdateState(
    _ store: ReduxStoreType,
    _ dispatchFn: (ReduxActionType) -> Void,
    _ lastStateFn: () -> GenericState<Int>)
  {
    /// Setup
    var original = 0

    /// When
    for _ in 0..<StoreTestParams.callCount {
      let action = Action.randomValue()!
      original = action.updateFn()(original)
      dispatchFn(action)
    }

    Thread.sleep(forTimeInterval: StoreTestParams.waitTime)

    /// Then
    let lastState = lastStateFn()
    let currentValue = lastState.value
    XCTAssertEqual(currentValue, original)
  }

  public func test_dispatchGenericAction_shouldUpdateState() {
    /// Setup
    let id = "Registrant"
    var actualCallCount = 0
    let mutex = NSLock()

    let addCallCount: () -> Void = {
      mutex.lock()
      defer { mutex.unlock() }
      actualCallCount += 1
    }

    genericStore!.register(id, {_ in addCallCount()})

    let dispatchFn: (ReduxActionType) -> Void = {(action: ReduxActionType) in
      let qos = DispatchQoS.QoSClass.randomValue()!

      DispatchQueue.global(qos: qos).async {
        self.genericStore!.dispatch(action)
      }
    }

    /// When & Then
    test_dispatchGenericBasedAction_shouldUpdateState(genericStore!,
                                                      dispatchFn,
                                                      {genericStore!.lastState()})

    // Add 1 to reflect initial value relay on first subscription.
    XCTAssertEqual(actualCallCount, StoreTestParams.callCount + 1)
  }
}
