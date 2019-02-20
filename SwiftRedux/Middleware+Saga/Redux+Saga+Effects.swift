//
//  Redux+Saga+Effects.swift
//  SwiftRedux
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import Foundation
import RxSwift
import SwiftFP

extension Redux.Saga.Effect {
  
  /// Create a call effect with an Observable.
  ///
  /// - Parameters:
  ///   - param: The parameter to call with.
  ///   - callCreator: The call creator function.
  /// - Returns: An Effect instance.
  public static func call<R2>(
    with param: Redux.Saga.Effect<State, R>,
    callCreator: @escaping (R) -> Observable<R2>)
    -> Redux.Saga.CallEffect<State, R, R2>
  {
    return Redux.Saga.CallEffect(param, callCreator)
  }
  
  /// Create a call effect with a callback-style async function.
  ///
  /// - Parameters:
  ///   - param: The parameter to call with.
  ///   - callCreator: The call creator function.
  /// - Returns: An Effect instance.
  public static func call<R2>(
    with param: Redux.Saga.Effect<State, R>,
    callCreator: @escaping (R, @escaping (Try<R2>) -> Void) -> Void)
    -> Redux.Saga.CallEffect<State, R, R2>
  {
    return call(with: param) {param in
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
  
  /// Create a call effect with a callback-style async function.
  ///
  /// - Parameters:
  ///   - param: The parameter to call with.
  ///   - callCreator: The call creator function.
  /// - Returns: An Effect instance.
  public static func call<R2>(
    with param: Redux.Saga.Effect<State, R>,
    callCreator: @escaping (R, @escaping (R2?, Error?) -> Void) -> Void)
    -> Redux.Saga.CallEffect<State, R, R2>
  {
    return call(with: param, callCreator: {(p, c: @escaping (Try<R2>) -> Void) in
      callCreator(p) {r, e in
        if let error = e {
          c(Try.failure(error))
        } else {
          c(Try<R>.from(r))
        }
      }
    })
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
    -> Redux.Saga.CatchErrorEffect<State, R>
  {
    return Redux.Saga.CatchErrorEffect(source, catcher)
  }
  
  /// Create a do-on-value effect.
  ///
  /// - Parameters:
  ///   - source: The source effect.
  ///   - selector: The side effect selector function.
  /// - Returns: An Effect instance.
  public static func doOnValue(
    _ source: Redux.Saga.Effect<State, R>,
    selector: @escaping (R) throws -> Void)
    -> Redux.Saga.DoOnValueEffect<State, R>
  {
    return Redux.Saga.DoOnValueEffect(source, selector)
  }
  
  /// Create a do-on-error effect.
  ///
  /// - Parameters:
  ///   - source: The source effect.
  ///   - selector: The side effect selector function.
  /// - Returns: An Effect instance.
  public static func doOnError(
    _ source: Redux.Saga.Effect<State, R>,
    selector: @escaping (Error) throws -> Void)
    -> Redux.Saga.DoOnErrorEffect<State, R>
  {
    return Redux.Saga.DoOnErrorEffect(source, selector)
  }
  
  /// Create an empty effect.
  ///
  /// - Returns: An Effect instance.
  public static func empty() -> Redux.Saga.EmptyEffect<State, R> {
    return Redux.Saga.EmptyEffect()
  }
  
  /// Create a filter effect.
  ///
  /// - Parameters:
  ///   - source: The source effect to be filtered.
  ///   - predicate: The filter predicate function.
  /// - Returns: An Effect instance.
  public static func filter(
    _ source: Redux.Saga.Effect<State, R>,
    predicate: @escaping (R) throws -> Bool) -> Redux.Saga.Effect<State, R>
  {
    return Redux.Saga.FilterEffect(source, predicate)
  }
  
  /// Create a just effect.
  ///
  /// - Parameter value: The value to form the effect with.
  /// - Returns: An Effect instance.
  public static func just(_ value: R) -> Redux.Saga.JustEffect<State, R> {
    return Redux.Saga.JustEffect(value)
  }
  
  /// Create a map effect.
  ///
  /// - Parameters:
  ///   - source: The source effect.
  ///   - mapper: The mapper function.
  /// - Returns: An Effect instance.
  public static func map<R2>(
    _ source: Redux.Saga.Effect<State, R>,
    withMapper mapper: @escaping (R) throws -> R2)
    -> Redux.Saga.MapEffect<State, R, R2>
  {
    return Redux.Saga.MapEffect(source, mapper)
  }
  
  /// Create a put effect.
  ///
  /// - Parameters:
  ///   - param: The parameter to put into Redux state.
  ///   - actionCreator: The action creator function.
  ///   - queue: The queue on which to dispatch the action.
  /// - Returns: An Effect instance.
  public static func put(
    _ param: Redux.Saga.Effect<State, R>,
    actionCreator: @escaping (R) -> ReduxActionType,
    usingQueue queue: DispatchQueue = .global(qos: .default))
    -> Redux.Saga.PutEffect<State, R>
  {
    return Redux.Saga.PutEffect(param, actionCreator, queue)
  }
  
  /// Convenience function to create a put effect with a raw value.
  ///
  /// - Parameters:
  ///   - param: The parameter to put into Redux state.
  ///   - actionCreator: The action creator function.
  ///   - queue: The queue on which to dispatch the action.
  /// - Returns: An Effect instance.
  public static func put(
    _ param: R,
    actionCreator: @escaping (R) -> ReduxActionType,
    usingQueue queue: DispatchQueue = .global(qos: .default))
    -> Redux.Saga.PutEffect<State, R>
  {
    return self.put(.just(param), actionCreator: actionCreator, usingQueue: queue)
  }
  
  /// Create a select effect.
  ///
  /// - Parameter selector: The state selector function.
  /// - Returns: An Effect instance.
  public static func select(_ selector: @escaping (State) -> R)
    -> Redux.Saga.SelectEffect<State, R>
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
  public static func sequentialize<State, R1, R2>(
    _ effect1: Redux.Saga.Effect<State, R1>,
    _ effect2: Redux.Saga.Effect<State, R2>,
    selector: @escaping (R1, R2) throws -> R)
    -> Redux.Saga.SequentializeEffect<State, R1, R2, R>
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
    -> Redux.Saga.DelayEffect<State, R>
  {
    return Redux.Saga.DelayEffect(source, sec, queue)
  }
  
  /// Create a take every effect.
  ///
  /// - Parameters:
  ///   - paramExtractor: The param extractor function.
  ///   - effectCreator: The effect creator function.
  ///   - options: Additional take options.
  /// - Returns: An Effect instance.
  public static func takeEvery<Action, R2>(
    paramExtractor: @escaping (Action) -> R?,
    effectCreator: @escaping (R) -> Redux.Saga.Effect<State, R2>,
    options: Redux.Saga.TakeOptions = .default())
    -> Redux.Saga.TakeEveryEffect<State, Action, R, R2> where
    Action: ReduxActionType
  {
    return Redux.Saga.TakeEveryEffect(paramExtractor, effectCreator, options)
  }
  
  /// Create a take latest effect.
  ///
  /// - Parameters:
  ///   - paramExtractor: The param extractor function.
  ///   - effectCreator: The effect creator function.
  ///   - options: Additinoal take options.
  /// - Returns: An Effect instance.
  public static func takeLatest<Action, R2>(
    paramExtractor: @escaping (Action) -> R?,
    effectCreator: @escaping (R) -> Redux.Saga.Effect<State, R2>,
    options: Redux.Saga.TakeOptions = .default())
    -> Redux.Saga.TakeLatestEffect<State, Action, R, R2> where
    Action: ReduxActionType
  {
    return Redux.Saga.TakeLatestEffect(paramExtractor, effectCreator, options)
  }
}
