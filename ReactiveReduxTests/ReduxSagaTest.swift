//
//  ReduxSagaTest.swift
//  ReactiveReduxTests
//
//  Created by Hai Pham on 12/5/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import XCTest
@testable import ReactiveRedux

final class ReduxSagaTest: XCTestCase {
  private var dispatch: Redux.Store.Dispatch!
  private var dispatchCount: Int!
  private var testEffect: TestEffect!
  
  override func setUp() {
    super.setUp()
    let input = Redux.Middleware.Input({()})
    let wrapper = Redux.Store.DispatchWrapper("", {_ in self.dispatchCount += 1})
    self.dispatchCount = 0
    self.testEffect = TestEffect()

    self.dispatch = Redux.Middleware.Saga
      .Provider(effects: [self.testEffect])
      .middleware(input)(wrapper).dispatch
  }
}

extension ReduxSagaTest {
  func test_receivingAction_shouldInvokeSagaEffects() {
    /// Setup && When
    self.dispatch(Redux.Preset.Action.noop)
    self.dispatch(Redux.Preset.Action.noop)
    self.dispatch(Redux.Preset.Action.noop)
    self.dispatch(Redux.Preset.Action.noop)
    
    /// Then
    XCTAssertEqual(self.testEffect.invokeCount, 1)
    XCTAssertEqual(self.testEffect.onActionCount, 4)
    
    XCTAssertEqual(self.testEffect.pastActions as! [Redux.Preset.Action],
                   [.noop, .noop, .noop, .noop])
  }
}

extension ReduxSagaTest {
  typealias State = ()
  
  final class TestEffect: Redux.Saga.Effect<State, Any> {
    var invokeCount: Int
    var onActionCount: Int
    var pastActions: [ReduxActionType]
    
    override init() {
      self.invokeCount = 0
      self.onActionCount = 0
      self.pastActions = []
    }
    
    override func invoke(_ input: Redux.Saga.Input<State>)
      -> Redux.Saga.Output<Any>
    {
      self.invokeCount += 1
      
      return Redux.Saga.Output(.empty()) {
        self.onActionCount += 1
        self.pastActions.append($0)
      }
    }
  }
}
