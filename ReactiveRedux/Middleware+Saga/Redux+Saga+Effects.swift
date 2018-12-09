//
//  Redux+Saga+Effects.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

extension Redux.Saga.Effect {
  
  /// Create a call effect with an Observable.
  ///
  /// - Parameters:
  ///   - param: The parameter to call with.
  ///   - callCreator: The call creator function.
  /// - Returns: An Effect instance.
  public static func call<P>(
    with param: Redux.Saga.Effect<State, P>,
    callCreator: @escaping (P) -> Observable<R>) -> Redux.Saga.Effect<State, R>
  {
    return Redux.Saga.CallEffect(param, callCreator)
  }
  
  /// Create a call effect with a callback-style async function.
  ///
  /// - Parameters:
  ///   - param: The parameter to call with.
  ///   - callCreator: The call creator function.
  /// - Returns: An Effect instance.
  public static func call<P>(
    with param: Redux.Saga.Effect<State, P>,
    callCreator: @escaping (P, @escaping (Try<R>) -> Void) -> Void)
    -> Redux.Saga.Effect<State, R>
  {
    return call(with: param) {(param) in
      return Observable.create({obs in
        callCreator(param, {
          do {
            obs.onNext(try $0.getOrThrow())
            obs.onCompleted()
          } catch let e {
            obs.onError(e)
          }
        })
        
        return Disposables.create()
      })
    }
  }
  
  /// Create a catch error effect.
  ///
  /// - Parameters:
  ///   - source: The source effect.
  ///   - catcher: The error catcher function.
  /// - Returns: An Effect instance.
  public static func catchError(
    _ source: Redux.Saga.Effect<State, R>,
    catcher: @escaping (Swift.Error) throws -> Redux.Saga.Effect<State, R>)
    -> Redux.Saga.Effect<State, R>
  {
    return Redux.Saga.CatchErrorEffect(source, catcher)
  }
  
  /// Create an empty effect.
  ///
  /// - Returns: An Effect instance.
  public static func empty() -> Redux.Saga.Effect<State, R> {
    return Redux.Saga.EmptyEffect()
  }
  
  /// Create a just effect.
  ///
  /// - Parameter value: The value to form the effect with.
  /// - Returns: An Effect instance.
  public static func just(_ value: R) -> Redux.Saga.Effect<State, R> {
    return Redux.Saga.JustEffect(value)
  }
  
  /// Create a map effect.
  ///
  /// - Parameters:
  ///   - source: The source effect.
  ///   - mapper: The mapper function.
  /// - Returns: An Effect instance.
  public static func map<E1, R2>(
    _ source: E1,
    withMapper mapper: @escaping (E1.R) throws -> R2)
    -> Redux.Saga.Effect<State, R2> where
    E1: ReduxSagaEffectType, E1.State == State
  {
    return Redux.Saga.MapEffect(source, mapper)
  }
  
  /// Create a put effect.
  ///
  /// - Parameters:
  ///   - param: The parameter to put into redux state.
  ///   - actionCreator: The action creator function.
  ///   - dispatchQueue: The queue on which to dispatch the action.
  /// - Returns: An Effect instance.
  public static func put<P>(
    _ param: Redux.Saga.Effect<State, P>,
    actionCreator: @escaping (P) -> ReduxActionType,
    dispatchQueue: DispatchQueue = .main) -> Redux.Saga.Effect<State, Any>
  {
    return Redux.Saga.PutEffect(param, actionCreator, dispatchQueue)
  }
  
  /// Create a select effect.
  ///
  /// - Parameter selector: The state selector function.
  /// - Returns: An Effect instance.
  public static func select(_ selector: @escaping (State) -> R)
    -> Redux.Saga.Effect<State, R>
  {
    return Redux.Saga.SelectEffect(selector)
  }
  
  /// Create a sequentialize effect.
  ///
  /// - Parameters:
  ///   - effect1: The first effect.
  ///   - effect2: The second effect that must happen after the first.
  ///   - selector: The result combine function.
  /// - Returns: An Effect instance.
  public static func sequentialize<E1, E2>(
    _ effect1: E1,
    _ effect2: E2,
    selector: @escaping (E1.R, E2.R) throws -> R)
    -> Redux.Saga.Effect<E2.State, R> where
    E1: ReduxSagaEffectType,
    E2: ReduxSagaEffectType,
    E1.State == State,
    E2.State == State
  {
    return Redux.Saga.SequentializeEffect(effect1, effect2, selector)
  }
  
  /// Create a delay effect.
  ///
  /// - Parameters:
  ///   - source: The source effect to be delayed.
  ///   - sec: The time in seconds to delay by.
  ///   - queue: The dispatch queue to delay on.
  /// - Returns: An Effect instance.
  public static func delay(
    _ source: Redux.Saga.Effect<State, R>,
    bySeconds sec: TimeInterval,
    usingQueue queue: DispatchQueue = .global(qos: .default))
    -> Redux.Saga.Effect<State, R>
  {
    return Redux.Saga.DelayEffect(source, sec, queue)
  }
  
  /// Create a take every effect.
  ///
  /// - Parameters:
  ///   - paramExtractor: The param extractor function.
  ///   - effectCreator: The effect creator function.
  ///   - outputTransformer: The output transformer to add functionalities.
  /// - Returns: An Effect instance.
  public static func takeEvery<Action, P>(
    paramExtractor: @escaping (Action) -> P?,
    effectCreator: @escaping (P) -> Redux.Saga.Effect<State, R>,
    outputTransformer: @escaping (Redux.Saga.Output<P>)
    -> Redux.Saga.Output<P> = {$0})
    -> Redux.Saga.Effect<State, R> where Action: ReduxActionType
  {
    return Redux.Saga.TakeEveryEffect
      .init(paramExtractor, effectCreator, outputTransformer)
  }
  
  /// Create a take latest effect.
  ///
  /// - Parameters:
  ///   - paramExtractor: The param extractor function.
  ///   - effectCreator: The effect creator function.
  ///   - outputTransformer: The output transformer to add functionalities.
  /// - Returns: An Effect instance.
  public static func takeLatest<Action, P>(
    paramExtractor: @escaping (Action) -> P?,
    effectCreator: @escaping (P) -> Redux.Saga.Effect<State, R>,
    outputTransformer: @escaping (Redux.Saga.Output<P>)
    -> Redux.Saga.Output<P> = {$0})
    -> Redux.Saga.Effect<State, R> where Action: ReduxActionType
  {
    return Redux.Saga.TakeLatestEffect
      .init(paramExtractor, effectCreator, outputTransformer)
  }
}
