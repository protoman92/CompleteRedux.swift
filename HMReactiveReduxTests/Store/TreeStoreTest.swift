//
//  TreeStoreTest.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxTest
import RxSwift
import SwiftFP
import SwiftUtilities
import SwiftUtilitiesTests
import XCTest
@testable import HMReactiveRedux

extension DispatchQoS.QoSClass: EnumerableType {
  public static func allValues() -> [DispatchQoS.QoSClass] {
    return [.background, .userInteractive, .userInitiated, .utility]
  }
}

public class SubState {
  public static let layer1 = "layer1"
  public static let layer2 = "layer2"
  public static let layer3 = "layer3"
}

public class State {
  public static let calculation = "calculation"
}

public final class TreeStoreTest: XCTestCase {
  fileprivate var disposeBag: DisposeBag!
  fileprivate var scheduler: TestScheduler!
  fileprivate var initialState: TreeState<Int>!
  fileprivate var treeStore: TreeDispatchStoreWrapper<Int>!
  fileprivate var rxStore: RxTreeStore<Int>!

  fileprivate var updateId: String {
    return "layer1.layer2.layer3.calculation"
  }

  override public func setUp() {
    super.setUp()
    continueAfterFailure = true
    scheduler = TestScheduler(initialClock: 0)
    disposeBag = DisposeBag()

    let layer3 = TreeState<Int>.builder()
      .updateValue(State.calculation, 0)
      .build()

    let layer2 = TreeState<Int>.builder()
      .updateSubstate(SubState.layer3, layer3)
      .build()

    let layer1 = TreeState<Int>.builder()
      .updateSubstate(SubState.layer2, layer2)
      .build()

    initialState = TreeState<Int>.builder()
      .updateSubstate(SubState.layer1, layer1)
      .build()

    let queue = DispatchQueue.global(qos: .userInteractive)
    treeStore = TreeDispatchStore.createInstance(initialState!, reduceTree, queue)
    rxStore = RxTreeStore<Int>.createInstance(initialState!, reduceTree)
  }

  fileprivate func reduceTree(_ state: TreeState<Int>,
                              _ action: ReduxActionType) -> TreeState<Int> {
    let action = action as! Action
    let updateFn = action.treeStateUpdateFn()
    return state.map(updateId, updateFn)
  }
}

public extension TreeStoreTest {
  public func test_dispatchTreeBasedAction_shouldUpdateState(
    _ store: ReduxStoreType,
    _ dispatchFn: (ReduxActionType) -> Void,
    _ lastStateFn: () -> TreeState<Int>,
    _ lastValueFn: () -> Try<Int>)
  {
    /// Setup
    var original = 0

    /// When
    for _ in 0..<StoreTestParams.callCount {
      let action = Action.randomValue()!
      original = action.treeStateUpdateFn()(Try.success(original)).value!
      dispatchFn(action)
    }

    Thread.sleep(forTimeInterval: StoreTestParams.waitTime)

    /// Then
    let lastState = lastStateFn()
    let lastValue = lastValueFn().value!
    let currentValue = lastState.stateValue(updateId).value!
    XCTAssertEqual(currentValue, original)
    XCTAssertEqual(currentValue, lastValue)
  }

  public func test_dispatchRxTreeAction_shouldUpdateState() {
    /// Setup
    let stateObs = scheduler.createObserver(TreeState<Int>.self)
    let substateObs = scheduler.createObserver(TreeState<Int>.self)
    let valueObs = scheduler.createObserver(Try<Int>.self)

    rxStore.stateStream()
      .subscribe(stateObs)
      .disposed(by: disposeBag!)

    rxStore.substateStream(updateId)
      .mapNonNilOrEmpty({$0.asOptional()})
      .subscribe(substateObs)
      .disposed(by: disposeBag!)

    rxStore.stateValueStream(Int.self, updateId)
      .subscribe(valueObs)
      .disposed(by: disposeBag!)

    /// When & Then
    test_dispatchTreeBasedAction_shouldUpdateState(rxStore!,
                                          {rxStore!.dispatch($0)},
                                          {stateObs.nextElements().last!},
                                          {valueObs.nextElements().last!})

    XCTAssertTrue(substateObs.nextElements().isEmpty)
  }

  public func test_dispatchCallbackTreeAction_shouldUpdateState() {
    /// Setup
    let id = "Registrant"
    let updateId = self.updateId
    var actualCallCount = 0
    let mutex = NSLock()

    let addCallCount: () -> Void = {
      mutex.lock()
      defer { mutex.unlock() }
      actualCallCount += 1
    }

    treeStore!.register(id, updateId, {_ in addCallCount()})

    let dispatchFn: (ReduxActionType) -> Void = {(action: ReduxActionType) in
      let qos = DispatchQoS.QoSClass.randomValue()!

      DispatchQueue.global(qos: qos).async {
        self.treeStore!.dispatch(action)
      }
    }

    /// When & Then 1
    test_dispatchTreeBasedAction_shouldUpdateState(treeStore!,
                                          dispatchFn,
                                          {treeStore!.lastState()},
                                          {treeStore!.lastValue(updateId)})

    // Add 1 to reflect initial value relay on first subscription.
    XCTAssertEqual(actualCallCount, StoreTestParams.callCount + 1)

    /// When & Then 2
    var unregistered = treeStore!.unregister(id)
    XCTAssertEqual(unregistered, 1)
    treeStore!.dispatch(Action.addTwo)
    XCTAssertEqual(actualCallCount, StoreTestParams.callCount + 1)

    /// When & Then 3
    unregistered = treeStore!.unregister(id)
    XCTAssertEqual(unregistered, 0)
  }
}
