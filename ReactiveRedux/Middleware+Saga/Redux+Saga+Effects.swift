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
  public typealias E = Redux.Saga.Effect
  typealias Call = Redux.Saga.CallEffect
  typealias Delay = Redux.Saga.DelayEffect
  typealias Empty = Redux.Saga.EmptyEffect
  typealias Just = Redux.Saga.JustEffect
  typealias Map = Redux.Saga.MapEffect
  typealias Put = Redux.Saga.PutEffect
  typealias Select = Redux.Saga.SelectEffect
  typealias Sequentialize = Redux.Saga.SequentializeEffect
  typealias TakeEvery = Redux.Saga.TakeEveryEffect
  typealias TakeLatest = Redux.Saga.TakeLatestEffect
  
  /// Create a call effect with an Observable.
  ///
  /// - Parameters:
  ///   - param: The parameter to call with.
  ///   - callCreator: The call creator function.
  /// - Returns: An Effect instance.
  public static func call<P>(
    with param: E<State, P>,
    callCreator: @escaping (P) -> Observable<R>) -> E<State, R>
  {
    return Call(param, callCreator)
  }
  
  /// Create a call effect with a callback-style async function.
  ///
  /// - Parameters:
  ///   - param: The parameter to call with.
  ///   - callCreator: The call creator function.
  /// - Returns: An Effect instance.
  public static func call<P>(
    with param: E<State, P>,
    callCreator: @escaping (P, @escaping (Try<R>) -> Void) -> Void) -> E<State, R>
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
  
  /// Create an empty effect.
  ///
  /// - Returns: An Effect instance.
  public static func empty() -> E<State, R> {
    return Empty()
  }
  
  /// Create a just effect.
  ///
  /// - Parameter value: The value to form the effect with.
  /// - Returns: An Effect instance.
  public static func just(_ value: R) -> E<State, R> {
    return Just(value)
  }
  
  /// Create a map effect.
  ///
  /// - Parameters:
  ///   - source: The source effect.
  ///   - mapper: The mapper function.
  /// - Returns: An Effect instance.
  public static func map<E1, R2>(
    _ source: E1,
    withMapper mapper: @escaping (E1.R) throws -> R2) -> E<State, R2> where
    E1: ReduxSagaEffectType, E1.State == State
  {
    return Map(source, mapper)
  }
  
  /// Create a put effect.
  ///
  /// - Parameters:
  ///   - param: The parameter to put into redux state.
  ///   - actionCreator: The action creator function.
  ///   - dispatchQueue: The queue on which to dispatch the action.
  /// - Returns: An Effect instance.
  public static func put<P>(
    _ param: E<State, P>,
    actionCreator: @escaping (P) -> ReduxActionType,
    dispatchQueue: DispatchQueue = .main) -> E<State, Any>
  {
    return Put(param, actionCreator, dispatchQueue)
  }
  
  /// Create a select effect.
  ///
  /// - Parameter selector: The state selector function.
  /// - Returns: An Effect instance.
  public static func select(_ selector: @escaping (State) -> R) -> E<State, R> {
    return Select(selector)
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
    selector: @escaping (E1.R, E2.R) throws -> R) -> E<E2.State, R> where
    E1: ReduxSagaEffectType,
    E2: ReduxSagaEffectType,
    E1.State == State,
    E2.State == State
  {
    return Sequentialize(effect1, effect2, selector)
  }
  
  /// Create a delay effect.
  ///
  /// - Parameters:
  ///   - source: The source effect to be delayed.
  ///   - sec: The time in seconds to delay by.
  ///   - queue: The dispatch queue to delay on.
  /// - Returns: An Effect instance.
  public static func delay(
    _ source: E<State, R>,
    bySeconds sec: TimeInterval,
    usingQueue queue: DispatchQueue = .global(qos: .default)) -> E<State, R>
  {
    return Delay(source, sec, queue)
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
    effectCreator: @escaping (P) -> E<State, R>,
    outputTransformer: @escaping (Redux.Saga.Output<P>)
    -> Redux.Saga.Output<P> = {$0})
    -> E<State, R> where Action: ReduxActionType
  {
    return TakeEvery(paramExtractor, effectCreator, outputTransformer)
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
    effectCreator: @escaping (P) -> E<State, R>,
    outputTransformer: @escaping (Redux.Saga.Output<P>)
    -> Redux.Saga.Output<P> = {$0})
    -> E<State, R> where Action: ReduxActionType
  {
    return TakeLatest(paramExtractor, effectCreator, outputTransformer)
  }
}
