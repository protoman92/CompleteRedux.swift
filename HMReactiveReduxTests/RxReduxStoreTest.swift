//
//  RxReduxStoreTest.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxTest
import RxSwift
import SafeNest
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

public final class RxReduxStoreTest: XCTestCase {
  fileprivate var disposeBag: DisposeBag!
  fileprivate var scheduler: TestScheduler!
  fileprivate var initialState: SafeNest!
  fileprivate var rxStore: RxReduxStore<SafeNest, Int>!
  fileprivate var actionsPerIter: Int!

  fileprivate var updateId: String {
    return "layer1.layer2.layer3.calculation"
  }

  override public func setUp() {
    super.setUp()
    continueAfterFailure = true
    self.scheduler = TestScheduler(initialClock: 0)
    self.disposeBag = DisposeBag()
    self.actionsPerIter = 5
    self.initialState = try! SafeNest().updating(value: 0, at: self.updateId)
    self.rxStore = RxReduxStore.createInstance(initialState!, self.reduce)
  }

  func reduce(_ state: SafeNest, _ action: ReduxActionType) -> SafeNest {
    switch action as? Action {
    case .some(let action):
      let updateFn = action.stateUpdateFn()
      return try! state.mapping(withMapper: updateFn, at: updateId)
      
    default:
      return state
    }
  }
}

public extension RxReduxStoreTest {
  public func test_dispatchSafeNestAction<Store>(
    _ store: Store,
    _ dispatchAllFn: ([Action]) -> Void,
    _ lastStateFn: () -> SafeNest,
    _ lastValueFn: () -> Try<Int>) where Store: ReduxStoreType
  {
    /// Setup
    var original = 0

    /// When
    for _ in 0..<StoreTestParams.callCount {
      var actions = [Action]()
      
      for _ in 0..<self.actionsPerIter! {
        let action = Action.randomValue()!
        original = action.stateUpdateFn()(original) as! Int
        actions.append(action)
      }

      dispatchAllFn(actions)

      let action1 = Action.randomValue()!
      original = action1.stateUpdateFn()(original) as! Int
      dispatchAllFn([action1])
    }

    Thread.sleep(forTimeInterval: StoreTestParams.waitTime)

    /// Then
    let lastState = lastStateFn()
    let lastValue = lastValueFn().value!
    let currentValue = lastState.value(at: self.updateId).value as! Int
    XCTAssertEqual(currentValue, original)
    XCTAssertEqual(currentValue, lastValue)
  }

  public func test_dispatchRxAction_shouldUpdateState() {
    /// Setup
    let valueObs = self.scheduler.createObserver(Try<Int>.self)

    self.rxStore.stateStream()
      .map({$0.value(at: self.updateId).cast(Int.self)})
      .subscribe(valueObs)
      .disposed(by: self.disposeBag!)

    /// When & Then
    test_dispatchSafeNestAction(self.rxStore!,
                                {self.rxStore!.dispatch($0)},
                                {self.rxStore.lastState.value!},
                                {valueObs.nextElements().last!})
  }
}
