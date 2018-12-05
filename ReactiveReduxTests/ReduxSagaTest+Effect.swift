//
//  ReduxSagaTest+Effect.swift
//  ReactiveReduxTests
//
//  Created by Hai Pham on 12/5/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import ReactiveRedux

final class ReduxSagaEffectTest: XCTestCase {
  func test_baseEffect_shouldThrowUnimplementedError() {
    /// Setup
    var dispatchCount = 0
    let dispatch: Redux.Store.Dispatch = {_ in dispatchCount += 1}
    let effect = Redux.Saga.Effect<State, Int>()
    let output = effect.invoke(withState: (), dispatch: dispatch)
    
    /// When
    dispatch(Redux.Preset.Action.noop)
    output.onAction(Redux.Preset.Action.noop)
    let value = output.nextValue(timeoutInSeconds: 2)
    
    /// Then
    XCTAssertEqual(dispatchCount, 1)
    XCTAssert(value.error is Redux.Saga.Error)
    XCTAssertEqual(value.error as? Redux.Saga.Error, .unimplemented)
  }
  
  func test_emptyEffect_shouldNotEmitAnything() {
    /// Setup
    var dispatchCount = 0
    let dispatch: Redux.Store.Dispatch = {_ in dispatchCount += 1}
    let effect = Redux.Saga.Effect<State, Int>.empty()
    let output = effect.invoke(withState: (), dispatch: dispatch)
    
    /// When
    dispatch(Redux.Preset.Action.noop)
    output.onAction(Redux.Preset.Action.noop)
    let value = output.nextValue(timeoutInSeconds: 2)
    
    /// Then
    XCTAssertEqual(dispatchCount, 1)
    XCTAssertTrue(value.isFailure)
  }
}

extension ReduxSagaEffectTest {
  typealias State = ()
}
