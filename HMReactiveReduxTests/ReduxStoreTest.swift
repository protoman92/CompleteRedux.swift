//
//  RxReduxStoreTest.swift
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

public enum Action: ReduxActionType, EnumerableType {
  case add
  case addTwo
  case addThree
  case minus

  public static func allValues() -> [Action] {
    return [add, addTwo, addThree, minus]
  }

  public func updateFn() -> TreeState<Int>.UpdateFn {
    switch self {
    case .add: return {$0.map({$0 + 1})}
    case .addTwo: return {$0.map({$0 + 2})}
    case .addThree: return {$0.map({$0 + 3})}
    case .minus: return {$0.map({$0 - 1})}
    }
  }
}

public final class RxReduxStoreTest: XCTestCase {
  fileprivate var disposeBag: DisposeBag!
  fileprivate var scheduler: TestScheduler!
  fileprivate var callCount: Int!
  fileprivate var initialState: TreeState<Int>!
  fileprivate var waitTime: TimeInterval!
  fileprivate var dispatchStore: DispatchStore<Int>!
  fileprivate var rxStore: RxStore<Int>!

  fileprivate var updateId: String {
    return "layer1.layer2.layer3.calculation"
  }

  override public func setUp() {
    super.setUp()
    scheduler = TestScheduler(initialClock: 0)
    disposeBag = DisposeBag()
    callCount = 1000
    waitTime = 1

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

    dispatchStore = DispatchStore.createInstance(initialState!, reduce)
    rxStore = RxStore<Int>.createInstance(initialState!, reduce)
  }

  fileprivate func reduce(_ state: TreeState<Int>, _ action: ReduxActionType) -> TreeState<Int> {
    switch action {
    case let action as Action:
      let updateFn = action.updateFn()
      return state.map(updateId, updateFn)

    default:
      return state
    }
  }

  public func test_dispatchAction_shouldUpdateState(
    _ store: ReduxStoreType,
    _ dispatchFn: (ReduxActionType) -> Void,
    _ lastStateFn: () -> TreeState<Int>,
    _ lastValueFn: () -> Try<Int>)
  {
    /// Setup
    var original = 0

    /// When
    for _ in 0..<callCount! {
      let action = Action.randomValue()!
      original = action.updateFn()(Try.success(original)).value!
      dispatchFn(action)
    }

    Thread.sleep(forTimeInterval: waitTime!)

    /// Then
    let lastState = lastStateFn()
    let lastValue = lastValueFn().value!
    let currentValue = lastState.stateValue(updateId).value!
    XCTAssertEqual(currentValue, original)
    XCTAssertEqual(currentValue, lastValue)
  }

  public func test_dispatchRxAction_shouldUpdateState() {
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
    test_dispatchAction_shouldUpdateState(rxStore!,
                                          {rxStore!.dispatch($0)},
                                          {stateObs.nextElements().last!},
                                          {valueObs.nextElements().last!})

    XCTAssertTrue(substateObs.nextElements().isEmpty)
  }

  public func test_dispatchNonRxAction_shouldUpdateState() {
    /// Setup
    let id = "Registrant"
    let updateId = self.updateId
    var actualCallCount = 0
    dispatchStore!.register(id, updateId, {_ in actualCallCount += 1})

    let dispatchFn: (ReduxActionType) -> Void = {(action: ReduxActionType) in
      let qos = DispatchQoS.QoSClass.randomValue()!

      DispatchQueue.global(qos: qos).async {
        self.dispatchStore!.dispatch(action)
      }
    }

    /// When & Then 1
    test_dispatchAction_shouldUpdateState(dispatchStore!,
                                          dispatchFn,
                                          {dispatchStore!.lastState()},
                                          {dispatchStore!.lastValue(updateId)})

    // Add 1 to reflect initial value relay on first subscription.
    XCTAssertEqual(actualCallCount, callCount! + 1)

    /// When & Then 2
    var didUnregister = dispatchStore!.unregister(id, updateId)
    dispatchStore!.dispatch(Action.addTwo)
    XCTAssertTrue(didUnregister)
    XCTAssertEqual(actualCallCount, callCount! + 1)

    /// When & Then 3
    didUnregister = dispatchStore!.unregister(id, updateId)
    XCTAssertFalse(didUnregister)

    /// When & Then 4
    let unregistered = dispatchStore!.unregisterAll(id)
    XCTAssertEqual(unregistered, 0)
  }

  public func test_removeCallbacksForDispatchStore_shouldWork() {
    /// Setup
    let ids = ["R1", "R2", "R3", "R4"]

    for id in ids {
      dispatchStore!.register(id, updateId, {_ in})
    }

    /// When
    let unregistered = dispatchStore!.unregisterAll(ids)

    /// Then
    XCTAssertEqual(unregistered, ids.count)
  }
}
