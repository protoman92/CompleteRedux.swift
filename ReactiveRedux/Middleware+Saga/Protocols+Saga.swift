//
//  Protocols+Saga.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/5/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Implement this protocol to represent a Redux saga effect.
public protocol ReduxSagaEffectType {
  associatedtype State
  associatedtype R
  
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
    return Redux.Saga.Effect.sequentialize(self, effect2, selector: selector)
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
