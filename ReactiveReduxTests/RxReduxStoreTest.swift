//
//  RxReduxStoreTest.swift
//  ReactiveReduxTests
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxSwift
import RxTest
import SafeNest
import SwiftFP
import XCTest
@testable import ReactiveRedux

final class RxReduxStoreTest: XCTestCase {
  private var disposeBag: DisposeBag!
  private var scheduler: TestScheduler!
  private var initialState: SafeNest!
  private var rxStore: Redux.Store.RxStore<SafeNest>!
  private var actionsPerIter: Int!

  private var updateId: String {
    return "layer1.layer2.layer3.calculation"
  }

  override func setUp() {
    super.setUp()
    self.scheduler = TestScheduler(initialClock: 0)
    self.disposeBag = DisposeBag()
    self.actionsPerIter = 5
    self.initialState = try! SafeNest.empty().updating(at: self.updateId, value: 0)
    self.rxStore = Redux.Store.RxStore.create(initialState!, self.reduce)
  }

  func reduce(_ state: SafeNest, _ action: ReduxActionType) -> SafeNest {
    switch action as? Action {
    case .some(let action):
      let updateFn = action.stateUpdateFn()
      return try! state.mapping(at: updateId, withMapper: updateFn)
      
    default:
      return state
    }
  }
}

extension RxReduxStoreTest {
  func test_dispatchSafeNestAction<Store>(
    _ store: Store,
    _ dispatchFn: (Action) -> Void,
    _ lastStateFn: Redux.Store.LastState<SafeNest>,
    _ lastValueFn: () -> Try<Int>) where Store: ReduxStoreType
  {
    /// Setup
    var original = 0

    /// When
    for _ in 0..<StoreTestParams.callCount {
      var actions = [Action]()
      
      for _ in 0..<self.actionsPerIter! {
        let action = Action.allValues().randomElement()!
        original = action.stateUpdateFn()(original) as! Int
        actions.append(action)
      }

      actions.forEach(dispatchFn)
      let action1 = Action.allValues().randomElement()!
      original = action1.stateUpdateFn()(original) as! Int
      dispatchFn(action1)
    }

    Thread.sleep(forTimeInterval: StoreTestParams.waitTime)

    /// Then
    let lastState = lastStateFn()
    let lastValue = lastValueFn().value!
    let currentValue = lastState.value(at: self.updateId).value as! Int
    XCTAssertEqual(currentValue, original)
    XCTAssertEqual(currentValue, lastValue)
  }

  func test_dispatchRxAction_shouldUpdateState() {
    /// Setup
    let valueObs = self.scheduler.createObserver(Try<Int>.self)

    self.rxStore.stateStream
      .map({$0.value(at: self.updateId).cast(Int.self)})
      .subscribe(valueObs)
      .disposed(by: self.disposeBag!)

    /// When & Then
    test_dispatchSafeNestAction(self.rxStore,
                                self.rxStore.dispatch,
                                self.rxStore.lastState,
                                {valueObs.events.map({$0.value.element!}).last!})
  }
}

extension RxReduxStoreTest {
  struct Substate: Decodable, Equatable {
    let a: Int?
    let b: Int?
  }
  
  func test_subscribeStore_shouldStreamAndStop() {
    /// Setup
    let iterations = 100
    var callbackCount = 0
    let subscription = self.rxStore.subscribeState("", {_ in callbackCount += 1})
    
    /// When
    (0..<iterations).forEach({_ in self.rxStore.stateTrigger.onNext(.empty())})
    subscription.unsubscribe()
    (0..<iterations).forEach({_ in self.rxStore.stateTrigger.onNext(.empty())})
    
    /// Then
    XCTAssertEqual(callbackCount, iterations + 1)
  }
}
