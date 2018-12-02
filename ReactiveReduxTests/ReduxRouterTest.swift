//
//  ReduxRouterTest.swift
//  ReactiveReduxTests
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import ReactiveRedux

final class ReduxRouterTest: XCTestCase {
  private var store: Redux.DelegateStore<State>!
  private var router: Router!
  
  override func setUp() {
    super.setUp()
    self.router = Router()

    self.store = Redux.applyMiddlewares(
      Redux.RouterMiddleware(self.router).middleware)(
      Redux.RxStore.create(State(), {(s, a) in s.increment()})
    )
  }
}

extension ReduxRouterTest {
  func test_navigateWithRouter_shouldWork() {
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

extension ReduxRouterTest {
  enum Screen: ReduxNavigationScreenType {
    case login
    case dashboard
  }
  
  final class Router: ReduxRouterType {
    typealias Screen = ReduxRouterTest.Screen
    
    var history: [Screen] = []
    
    func navigate(_ screen: ReduxRouterTest.Screen) {
      self.history.append(screen)
    }
  }
  
  struct State {
    var a = -1
    
    func increment() -> State {
      return State(a: self.a + 1)
    }
  }
}

extension ReduxRouterTest.Screen: Equatable {}
