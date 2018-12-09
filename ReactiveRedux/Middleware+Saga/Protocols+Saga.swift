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
