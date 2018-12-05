//
//  ReduxSagaTest+Effect.swift
//  ReactiveReduxTests
//
//  Created by Hai Pham on 12/5/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP
import RxSwift
import XCTest
@testable import ReactiveRedux

final class ReduxSagaEffectTest: XCTestCase {
  func test_baseEffect_shouldThrowUnimplementedError() {
    /// Setup
    var dispatchCount = 0
    let dispatch: Redux.Store.Dispatch = {_ in dispatchCount += 1}
    let effect = Effect<State, Int>()
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
    let effect = Effect<State, Int>.empty()
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
    let effect = Effect<State, Int>.just(10)
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
    let effect = Effect<State, Int>.select({_ in 100})
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
    let paramEffect = Effect<State, Int>.just(200)

    let effect = Effect<State, Any>.put(
      paramEffect,
      actionCreator: Action.input,
      dispatchQueue: DispatchQueue.global(qos: .default))
    
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
  
  func test_callEffect_shouldPerformAsyncWork() {
    /// Setup
    var dispatchCount = 0
    let dispatch: Redux.Store.Dispatch = {_ in dispatchCount += 1}
    
    let api1: (Int, @escaping (Try<Int>) -> Void) -> Void = {param, callback in
      let delayTime = UInt64(2 * pow(10 as Double, 9))
      let finalTime = DispatchTime.now().uptimeNanoseconds + delayTime

      DispatchQueue.global(qos: .background).asyncAfter(
        deadline: DispatchTime(uptimeNanoseconds: finalTime),
        execute: {callback(Try.success(param))
      })
    }
    
    let api2: (Int) -> Observable<Int> = {_ in
      .error(Redux.Saga.Error.unimplemented)
    }

    let paramEffect = Effect<State, Int>.just(300)
    let effect1 = Effect.call(param: paramEffect, callCreator: api1)
    let effect2 = Effect.call(param: paramEffect, callCreator: api2)
    let output1 = effect1.invoke(withState: (), dispatch: dispatch)
    let output2 = effect2.invoke(withState: (), dispatch: dispatch)
    
    /// When
    let value1 = output1.nextValue(timeoutInSeconds: 3)
    let value2 = output2.nextValue(timeoutInSeconds: 3)
    
    /// Then
    XCTAssertEqual(value1.value, 300)
    XCTAssertTrue(value2.isFailure)
  }
  
  func test_sequentializeEffect_shouldEnsureExecutionOrder() {
    /// Setup
    var dispatchCount = 0
    let dispatch: Redux.Store.Dispatch = {_ in dispatchCount += 1}
    
    let effect1 = Effect<State, Int>.call(param: .just(1)) {
      let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
      return Observable.just($0).delay(2, scheduler: scheduler)
    }
    
    let effect2 = Effect<State, Int>.just(2)
    let sequentialized = Redux.Saga.Effect.sequentialize(effect1, effect2)
    let output = sequentialized.invoke(withState: (), dispatch: dispatch)
    
    /// When
    let value = output.nextValue(timeoutInSeconds: 3)
    
    /// Then
    XCTAssertEqual(value.value, 2)
  }
}

extension ReduxSagaEffectTest {
  enum TakeAction: ReduxActionType {
    case a
    case b
    
    var payload: Int? {
      switch self {
      case .a: return 1
      case .b: return nil
      }
    }
  }
  
  func test_takeEffect_shouldTakeAppropriateActions(
    creator: (@escaping (Int) -> Effect<State, Int>) -> Effect<State, Int>,
    outputValues: [Int])
  {
    /// Setup
    var dispatchCount = 0
    let dispatch: Redux.Store.Dispatch = {_ in dispatchCount += 1}
    
    let callEffectCreator: (Int) -> Effect<State, Int> = {
      Effect.call(param: .just($0)) {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
        return Observable.just($0).delay(2, scheduler: scheduler)
      }
    }
    
    let effect = creator(callEffectCreator)
    let output = effect.invoke(withState: (), dispatch: dispatch)
    var values: [Int] = []
    
    /// When
    output.subscribe({values.append($0)})
    output.onAction(TakeAction.a)
    output.onAction(TakeAction.b)
    output.onAction(TakeAction.a)
    output.onAction(Redux.Preset.Action.noop)
    output.onAction(TakeAction.a)
    
    /// Then
    let waitTime = UInt64(pow(10 as Double, 9) * 3)
    let timeout = DispatchTime.now().uptimeNanoseconds + waitTime
    let deadline = DispatchTime(uptimeNanoseconds: timeout)
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    
    DispatchQueue.global(qos: .background).asyncAfter(deadline: deadline) {
      dispatchGroup.leave()
    }
    
    dispatchGroup.wait()
    XCTAssertEqual(values, outputValues)
  }
  
  func test_takeEveryEffect_shouldTakeAllAction() {
    self.test_takeEffect_shouldTakeAppropriateActions(
      creator: {Effect.takeEvery(
        actionType: TakeAction.self,
        paramExtractor: {$0.payload},
        effectCreator: $0)},
      outputValues: [1, 1, 1])
  }
  
  func test_takeLatestEffect_shouldTakeLatestAction() {
    self.test_takeEffect_shouldTakeAppropriateActions(
      creator: {Effect.takeLatest(
        actionType: TakeAction.self,
        paramExtractor: {$0.payload},
        effectCreator: $0)},
      outputValues: [1])
  }
}

extension ReduxSagaEffectTest {
  typealias State = ()
  typealias Effect = Redux.Saga.Effect
}
