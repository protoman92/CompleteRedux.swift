//
//  ReduxMiddlewareTest.swift
//  ReactiveReduxTests
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import ReactiveRedux

final class ReduxMiddlewareTest: XCTestCase {
  private var store: Redux.Store.RxStore<State>!
  
  override func setUp() {
    super.setUp()
    let initState = State(a: -1)
    self.store = Redux.Store.RxStore.create(initState, {s, a in s.increment()})
  }
}

extension ReduxMiddlewareTest {
  func test_applyingMiddlewares_shouldWrapBaseStore() {
    /// Setup
    var data: [Int] = []
    var subscribedValue = 0
    
    let wrappedStore = Redux.Middleware.applyMiddlewares(
      {input in {dispatch in {data.append(1); dispatch($0)}}},
      {input in {dispatch in {data.append(2); dispatch($0)}}},
      {input in {dispatch in {data.append(3); dispatch($0)}}}
    )(self.store)
    
    let subscription = wrappedStore.subscribeState("", {subscribedValue = $0.a})
    
    /// When
    wrappedStore.dispatch(Redux.Preset.Action.noop)
    wrappedStore.dispatch(Redux.Preset.Action.noop)
    wrappedStore.dispatch(Redux.Preset.Action.noop)
    
    /// Then
    XCTAssertEqual(data, [1, 2, 3, 1, 2, 3, 1, 2, 3])
    XCTAssertEqual(wrappedStore.lastState().a, 3)
    XCTAssertEqual(subscribedValue, 3)
    subscription.unsubscribe()
  }
}

extension ReduxMiddlewareTest {
  struct State {
    let a: Int
    
    func increment() -> State {
      return State(a: self.a + 1)
    }
  }
}
