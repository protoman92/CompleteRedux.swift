//
//  Protocols+Saga.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/5/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Implement this protocol to convert to an effect instance.
public protocol ReduxSagaEffectConvertibleType {
  associatedtype State
  associatedtype R
  
  func asEffect() -> Redux.Saga.Effect<State, R>
}

/// Implement this protocol to represent a Redux saga effect.
public protocol ReduxSagaEffectType: ReduxSagaEffectConvertibleType {
  
  /// Create an output stream from a redux store's internal functionalities.
  ///
  /// - Parameter input: A Saga Input instance.
  /// - Returns: A Saga Output instance.
  func invoke(_ input: Redux.Saga.Input<State>) -> Redux.Saga.Output<R>
}

extension ReduxSagaEffectType {
  public func invoke(withState state: State,
                     dispatch: @escaping Redux.Store.Dispatch)
    -> Redux.Saga.Output<R>
  {
    return self.invoke(Redux.Saga.Input({state}, dispatch))
  }
  
  /// Feed the current effect as input to create another effect.
  ///
  /// - Parameter effectCreator: The effect creator function.
  /// - Returns: An Effect instance.
  public func asInput<R>(
    for effectCreator: (Self) throws -> Redux.Saga.Effect<State, R>)
    rethrows -> Redux.Saga.Effect<State, R>
  {
    return try effectCreator(self)
  }
  
  /// Invoke a call effect on the current effect.
  ///
  /// - Parameter callCreator: A call creator function.
  /// - Returns: An Effect instance.
  public func call<R2>(_ callCreator: @escaping (R) -> Observable<R2>)
    -> Redux.Saga.Effect<State, R2>
  {
    return self.asEffect()
      .asInput(for: {.call(with: $0, callCreator: callCreator)})
  }
  
  /// Invoke a call effect on the current effect.
  ///
  /// - Parameter callCreator: A call creator function.
  /// - Returns: An Effect instance.
  public func call<R2>(
    _ callCreator: @escaping (R, @escaping (Try<R2>) -> Void) -> Void)
    -> Redux.Saga.Effect<State, R2>
  {
    return self.asEffect()
      .asInput(for: {.call(with: $0, callCreator: callCreator)})
  }
  
  /// Invoke a map effect on the current effect.
  ///
  /// - Parameter mapper: The mapper function.
  /// - Returns: An Effect instance.
  public func map<R2>(_ mapper: @escaping (R) throws -> R2)
    -> Redux.Saga.Effect<State, R2>
  {
    return self.asInput(for: {.map($0, withMapper: mapper)})
  }
  
  /// Invoke a put effect on the current effect.
  ///
  /// - Parameters:
  ///   - actionCreator: The action creator function.
  ///   - dispatchQueue: The dispatch queue on which to put.
  /// - Returns: An Effect instance.
  public func put(
    _ actionCreator: @escaping (R) -> ReduxActionType,
    dispatchQueue: DispatchQueue = .main)
    -> Redux.Saga.Effect<State, Any>
  {
    return self.asEffect().asInput(for: {
      .put($0, actionCreator: actionCreator, dispatchQueue: dispatchQueue)})
  }
  
  /// Invoke a delay effect on the current effect.
  ///
  /// - Parameters:
  ///   - sec: The time interval to delay by.
  ///   - queue: The queue to delay on.
  /// - Returns: An Effect instance.
  public func delay(
    bySeconds sec: TimeInterval,
    usingQueue queue: DispatchQueue = .global(qos: .default))
    -> Redux.Saga.Effect<State, R>
  {
    return self.asEffect()
      .asInput(for: {.delay($0, bySeconds: sec, usingQueue: queue)})
  }
  
  /// Trigger another effect in sequence and combining emissions with a
  /// selector function.
  ///
  /// - Parameters:
  ///   - effect2: An Effect instance.
  ///   - selector: The selector function.
  /// - Returns: An Effect instance.
  public func then<R2, U>(
    _ effect2: Redux.Saga.Effect<State, R2>,
    selector: @escaping (R, R2) throws -> U)
    -> Redux.Saga.Effect<State, U>
  {
    return self.asInput(for: {.sequentialize($0, effect2, selector: selector)})
  }
  
  /// Trigger another event and ignore emission from this effect.
  ///
  /// - Parameter effect2: An Effect instance.
  /// - Returns: An Effect instance.
  public func then<R2>(_ effect2: Redux.Saga.Effect<State, R2>)
    -> Redux.Saga.Effect<State, R2>
  {
    return self.then(effect2, selector: {$1})
  }
}

/// Implement this protocol to represent a take effect (e.g. take latest or
/// take every).
public protocol ReduxSagaTakeEffectType: ReduxSagaEffectType {
  associatedtype Action: ReduxActionType
  associatedtype P
  
  init(_ actionType: Action.Type,
       _ paramExtractor: @escaping (Action) -> P?,
       _ outputCreator: @escaping (P) -> Redux.Saga.Effect<State, R>)
}
