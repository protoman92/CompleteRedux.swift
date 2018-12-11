//
//  Protocols+Saga.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/5/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Implement this protocol to convert to an effect instance.
public protocol ReduxSagaEffectConvertibleType {
  
  /// The app-specific state type.
  associatedtype State
  
  /// The type of the effect's output value.
  associatedtype R
  
  /// Convert the current object into an Effect.
  ///
  /// - Returns: An Effect instance.
  func asEffect() -> Redux.Saga.Effect<State, R>
}

/// Implement this protocol to represent a Redux saga effect.
public protocol ReduxSagaEffectType: ReduxSagaEffectConvertibleType {
  
  /// Create an output stream from a Redux store's internal functionalities.
  ///
  /// - Parameter input: A Saga Input instance.
  /// - Returns: A Saga Output instance.
  func invoke(_ input: Redux.Saga.Input<State>) -> Redux.Saga.Output<R>
}

extension ReduxSagaEffectConvertibleType {

  /// Feed the current effect as input to create another effect.
  ///
  /// - Parameter effectCreator: The effect creator function.
  /// - Returns: An Effect instance.
  public func transform<R2>(
    with effectCreator: Redux.Saga.EffectTransformer<State, R, R2>)
    -> Redux.Saga.Effect<State, R2>
  {
    return effectCreator(self.asEffect())
  }
}

extension ReduxSagaEffectType {
  
  /// Create an output stream from input parameters. This is useful during
  /// testing to reduce boilerplate w.r.t the creation of saga input.
  ///
  /// - Parameters:
  ///   - state: A State instance.
  ///   - dispatch: The action dispatch function.
  /// - Returns: An Output instance.
  public func invoke(withState state: State,
                     dispatch: @escaping Redux.Store.Dispatch)
    -> Redux.Saga.Output<R>
  {
    return self.invoke(Redux.Saga.Input({state}, dispatch))
  }
}
