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
  private var dispatch: Redux.Store.Dispatch!
  private var dispatchCount: Int!
  private var router: Router!
  
  override func setUp() {
    super.setUp()
    _ = Redux.Middleware.Router()
    let input = Redux.Middleware.Input({()})
    let wrapper = Redux.Store.DispatchWrapper("", {_ in self.dispatchCount += 1})
    self.router = Router()
    self.dispatchCount = 0

    self.dispatch = Redux.Middleware.Router.Provider(router: self.router)
      .middleware(input)(wrapper).dispatch
  }
}

extension ReduxRouterTest {
  func test_navigateWithRouter_shouldWork() {
    /// Setup
    let expect = expectation(description: "Should have navigated")
    self.router.navigateCallback = { if $0 == 3 { expect.fulfill() } }
    
    /// When
    self.dispatch(Screen.login)
    self.dispatch(Screen.dashboard)
    self.dispatch(Screen.login)
    self.dispatch(Redux.Preset.Action.noop)
    
    /// Then
    waitForExpectations(timeout: 10, handler: nil)
    XCTAssertEqual(self.router.history, [.login, .dashboard, .login])
    XCTAssertEqual(self.dispatchCount, 4)
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
    var navigateCallback: ((Int) -> Void)?
    
    func navigate(_ screen: ReduxRouterTest.Screen) {
      self.history.append(screen)
      self.navigateCallback?(self.history.count)
    }
  }
}

extension ReduxRouterTest.Screen: Equatable {}
