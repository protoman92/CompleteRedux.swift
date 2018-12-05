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
    
    let middlewares: [Redux.Middleware.Middleware<State>] = [
      {input in {wrapper in Redux.Store.DispatchWrapper(
        "\(wrapper.identifier)-1",
        {data.append(1); wrapper.dispatch($0)})}},
      {input in {wrapper in Redux.Store.DispatchWrapper(
        "\(wrapper.identifier)-2",
        {data.append(2); wrapper.dispatch($0)})}},
      {input in {wrapper in Redux.Store.DispatchWrapper(
        "\(wrapper.identifier)-3",
        {data.append(3); wrapper.dispatch($0)})}}
    ]
    
    let wrapper = Redux.Middleware.combineMiddlewares(middlewares)(self.store)
    let newStore = Redux.Middleware.applyMiddlewares(middlewares)(self.store)
    let subscription = newStore.subscribeState("", {subscribedValue = $0.a})
    
    /// When
    newStore.dispatch(Redux.Preset.Action.noop)
    newStore.dispatch(Redux.Preset.Action.noop)
    newStore.dispatch(Redux.Preset.Action.noop)
    
    /// Then
    XCTAssertEqual(wrapper.identifier, "root-3-2-1")
    XCTAssertEqual(data, [1, 2, 3, 1, 2, 3, 1, 2, 3])
    XCTAssertEqual(newStore.lastState().a, 3)
    XCTAssertEqual(subscribedValue, 3)
    subscription.unsubscribe()
  }
  
  func test_wrappingWithNoMiddlewares_shouldReturnBaseDispatch() {
    /// Setup && When
    let wrapper = Redux.Middleware.combineMiddlewares([])(self.store)
    
    /// Then
    XCTAssertEqual(wrapper.identifier, "root")
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
