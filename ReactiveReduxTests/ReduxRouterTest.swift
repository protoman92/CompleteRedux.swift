//
//  ReduxRouterTest.swift
//  ReactiveReduxTests
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import XCTest
@testable import ReactiveRedux

public final class ReduxRouterTest: XCTestCase {
  private var store: Redux.DelegateStore<State>!
  private var router: Router!
  
  override public func setUp() {
    super.setUp()
    self.router = Router()

    self.store = Redux.applyMiddlewares(
      Redux.extractMiddleware(Redux.RouterMiddleware(self.router)))(
      Redux.RxStore.create(State(), {(s, a) in s.increment()})
    )
  }
}

public extension ReduxRouterTest {
  public func test_navigateWithRouter_shouldWork() {
    /// Setup && When
    self.store.dispatch(Screen.login)
    self.store.dispatch(Screen.dashboard)
    self.store.dispatch(Screen.login)
    self.store.dispatch(Redux.DefaultAction.noop)
    
    /// Then
    DispatchQueue.main.async {
      XCTAssertEqual(self.router.history, [.login, .dashboard, .login])
      XCTAssertEqual(self.store.lastState().a, 4)
    }
  }
}

public extension ReduxRouterTest {
  public enum Screen: ReduxNavigationScreenType {
    case login
    case dashboard
  }
  
  public final class Router: ReduxRouterType {
    public typealias Screen = ReduxRouterTest.Screen
    
    public var history: [Screen] = []
    
    public func navigate(_ screen: ReduxRouterTest.Screen) {
      self.history.append(screen)
    }
  }
  
  public struct State {
    public var a = -1
    
    public func increment() -> State {
      return State(a: self.a + 1)
    }
  }
}

extension ReduxRouterTest.Screen: Equatable {}
