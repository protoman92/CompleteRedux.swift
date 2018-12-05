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
  
  func test_justEffect_shouldEmitOnlyOneValue() {
    /// Setup
    var dispatchCount = 0
    let dispatch: Redux.Store.Dispatch = {_ in dispatchCount += 1}
    let effect = Redux.Saga.Effect<State, Int>.just(10)
    let output = effect.invoke(withState: (), dispatch: dispatch)
    
    /// When
    dispatch(Redux.Preset.Action.noop)
    output.onAction(Redux.Preset.Action.noop)
    let value1 = output.nextValue(timeoutInSeconds: 2)
    let value2 = output.nextValue(timeoutInSeconds: 2)
    let value3 = output.nextValue(timeoutInSeconds: 2)
    
    /// Then
    XCTAssertEqual(dispatchCount, 1)
    [value1, value2, value3].forEach({XCTAssertEqual($0.value, 10)})
  }
  
  func test_selectEffect_shouldEmitOnlySelectedStateValue() {
    /// Setup
    var dispatchCount = 0
    let dispatch: Redux.Store.Dispatch = {_ in dispatchCount += 1}
    let effect = Redux.Saga.Effect<State, Int>.select({_ in 100})
    let output = effect.invoke(withState: (), dispatch: dispatch)
    
    /// When
    dispatch(Redux.Preset.Action.noop)
    output.onAction(Redux.Preset.Action.noop)
    let value1 = output.nextValue(timeoutInSeconds: 2)
    let value2 = output.nextValue(timeoutInSeconds: 2)
    let value3 = output.nextValue(timeoutInSeconds: 2)
    
    /// Then
    XCTAssertEqual(dispatchCount, 1)
    [value1, value2, value3].forEach({XCTAssertEqual($0.value, 100)})
  }
  
  func test_putEffect_shouldDispatchPutEffect() {
    /// Setup
    enum Action: ReduxActionType { case input(Int) }
    var dispatchCount = 0
    var actions: [ReduxActionType] = []
    let dispatch: Redux.Store.Dispatch = {dispatchCount += 1; actions.append($0)}
    let paramEffect = Redux.Saga.Effect<State, Int>.just(200)

    let effect = Redux.Saga.Effect<State, Any>
      .put(paramEffect, actionCreator: Action.input)
    
    let output = effect.invoke(withState: (), dispatch: dispatch)
    
    /// When
    dispatch(Redux.Preset.Action.noop)
    output.onAction(Redux.Preset.Action.noop)
    _ = output.nextValue(timeoutInSeconds: 2)
    
    /// Then
    XCTAssertEqual(dispatchCount, 2)
    XCTAssertEqual(actions.count, 2)
    XCTAssert(actions[0] is Redux.Preset.Action)
    XCTAssert(actions[1] is Action)
    let action = actions[1] as! Action
    
    if case let .input(value) = action {
      XCTAssertEqual(value, 200)
    } else {
      XCTFail("Should not have reached here")
    }
  }
}

extension ReduxSagaEffectTest {
  typealias State = ()
}
