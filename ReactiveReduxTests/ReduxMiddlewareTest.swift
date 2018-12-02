//
//  ReduxMiddlewareTest.swift
//  ReactiveReduxTests
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import ReactiveRedux

public final class ReduxMiddlewareTest: XCTestCase {
  private var store: Redux.RxStore<State>!
  
  override public func setUp() {
    super.setUp()
    self.store = Redux.RxStore.create(State(a: -1), {s, a in s.increment()})
  }
}

public extension ReduxMiddlewareTest {
  public func test_applyingMiddlewares_shouldWrapBaseStore() {
    /// Setup
    var data: [Int] = []
    var subscribedValue = 0
    
    let wrappedStore = Redux.applyMiddlewares(
      {input in {data.append(1); input.dispatch($0)}},
      {input in {data.append(2); input.dispatch($0)}},
      {input in {data.append(3); input.dispatch($0)}}
    )(self.store)
    
    let subscription = wrappedStore.subscribeState("", {subscribedValue = $0.a})
    
    /// When
    wrappedStore.dispatch(Redux.DefaultAction.noop)
    wrappedStore.dispatch(Redux.DefaultAction.noop)
    wrappedStore.dispatch(Redux.DefaultAction.noop)
    
    /// Then
    XCTAssertEqual(data, [1, 2, 3, 1, 2, 3, 1, 2, 3])
    XCTAssertEqual(wrappedStore.lastState().a, 3)
    XCTAssertEqual(subscribedValue, 3)
    subscription.unsubscribe()
  }
}

public extension ReduxMiddlewareTest {
  public struct State {
    public let a: Int
    
    public func increment() -> State {
      return State(a: self.a + 1)
    }
  }
}
