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

extension SagaEffect {
  
  /// Create a call effect with an Observable.
  ///
  /// - Parameters:
  ///   - param: The parameter to call with.
  ///   - callCreator: The call creator function.
  /// - Returns: An Effect instance.
  public static func call<R2>(
    with param: SagaEffect<State, R>,
    callCreator: @escaping (R) -> Observable<R2>)
    -> CallEffect<State, R, R2>
  {
    return CallEffect(param, callCreator)
  }
  
  /// Create a call effect with a callback-style async function.
  ///
  /// - Parameters:
  ///   - param: The parameter to call with.
  ///   - callCreator: The call creator function.
  /// - Returns: An Effect instance.
  public static func call<R2>(
    with param: SagaEffect<State, R>,
    callCreator: @escaping (R, @escaping (Try<R2>) -> Void) -> Void)
    -> CallEffect<State, R, R2>
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
    with param: SagaEffect<State, R>,
    callCreator: @escaping (R, @escaping (R2?, Error?) -> Void) -> Void)
    -> CallEffect<State, R, R2>
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
    _ source: SagaEffect<State, R>,
    catcher: @escaping (Swift.Error) throws -> SagaEffect<State, R>)
    -> CatchErrorEffect<State, R>
  {
    return CatchErrorEffect(source, catcher)
  }
  
  /// Create a do-on-value effect.
  ///
  /// - Parameters:
  ///   - source: The source effect.
  ///   - selector: The side effect selector function.
  /// - Returns: An Effect instance.
  public static func doOnValue(
    _ source: SagaEffect<State, R>,
    selector: @escaping (R) throws -> Void)
    -> DoOnValueEffect<State, R>
  {
    return DoOnValueEffect(source, selector)
  }
  
  /// Create a do-on-error effect.
  ///
  /// - Parameters:
  ///   - source: The source effect.
  ///   - selector: The side effect selector function.
  /// - Returns: An Effect instance.
  public static func doOnError(
    _ source: SagaEffect<State, R>,
    selector: @escaping (Error) throws -> Void)
    -> DoOnErrorEffect<State, R>
  {
    return DoOnErrorEffect(source, selector)
  }
  
  /// Create an empty effect.
  ///
  /// - Returns: An Effect instance.
  public static func empty() -> EmptyEffect<State, R> {
    return EmptyEffect()
  }
  
  /// Create a filter effect.
  ///
  /// - Parameters:
  ///   - source: The source effect to be filtered.
  ///   - predicate: The filter predicate function.
  /// - Returns: An Effect instance.
  public static func filter(
    _ source: SagaEffect<State, R>,
    predicate: @escaping (R) throws -> Bool) -> SagaEffect<State, R>
  {
    return FilterEffect(source, predicate)
  }
  
  /// Create a just effect.
  ///
  /// - Parameter value: The value to form the effect with.
  /// - Returns: An Effect instance.
  public static func just(_ value: R) -> JustEffect<State, R> {
    return JustEffect(value)
  }
  
  /// Create a map effect.
  ///
  /// - Parameters:
  ///   - source: The source effect.
  ///   - mapper: The mapper function.
  /// - Returns: An Effect instance.
  public static func map<R2>(
    _ source: SagaEffect<State, R>,
    withMapper mapper: @escaping (R) throws -> R2)
    -> MapEffect<State, R, R2>
  {
    return MapEffect(source, mapper)
  }
  
  /// Create a put effect.
  ///
  /// - Parameters:
  ///   - param: The parameter to put into Redux state.
  ///   - actionCreator: The action creator function.
  ///   - queue: The queue on which to dispatch the action.
  /// - Returns: An Effect instance.
  public static func put(
    _ param: SagaEffect<State, R>,
    actionCreator: @escaping (R) -> ReduxActionType,
    usingQueue queue: DispatchQueue = .global(qos: .default))
    -> PutEffect<State, R>
  {
    return PutEffect(param, actionCreator, queue)
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
    -> PutEffect<State, R>
  {
    return self.put(.just(param), actionCreator: actionCreator, usingQueue: queue)
  }
  
  /// Create a select effect.
  ///
  /// - Parameter selector: The state selector function.
  /// - Returns: An Effect instance.
  public static func select(_ selector: @escaping (State) -> R) -> SelectEffect<State, R> {
    return SelectEffect(selector)
  }
  
  /// Create a sequentialize effect.
  ///
  /// - Parameters:
  ///   - effect1: The first effect.
  ///   - effect2: The second effect that must happen after the first.
  ///   - selector: The result combine function.
  /// - Returns: An Effect instance.
  public static func sequentialize<State, R1, R2>(
    _ effect1: SagaEffect<State, R1>,
    _ effect2: SagaEffect<State, R2>,
    selector: @escaping (R1, R2) throws -> R)
    -> SequentializeEffect<State, R1, R2, R>
  {
    return SequentializeEffect(effect1, effect2, selector)
  }
  
  /// Create a delay effect.
  ///
  /// - Parameters:
  ///   - source: The source effect to be delayed.
  ///   - sec: The time in seconds to delay by.
  ///   - queue: The dispatch queue to delay on.
  /// - Returns: An Effect instance.
  public static func delay(
    _ source: SagaEffect<State, R>,
    bySeconds sec: TimeInterval,
    usingQueue queue: DispatchQueue = .global(qos: .default))
    -> DelayEffect<State, R>
  {
    return DelayEffect(source, sec, queue)
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
    effectCreator: @escaping (R) -> SagaEffect<State, R2>,
    options: TakeOptions = .default())
    -> TakeEveryEffect<State, Action, R, R2> where
    Action: ReduxActionType
  {
    return TakeEveryEffect(paramExtractor, effectCreator, options)
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
    effectCreator: @escaping (R) -> SagaEffect<State, R2>,
    options: TakeOptions = .default())
    -> TakeLatestEffect<State, Action, R, R2> where
    Action: ReduxActionType
  {
    return TakeLatestEffect(paramExtractor, effectCreator, options)
  }
}
