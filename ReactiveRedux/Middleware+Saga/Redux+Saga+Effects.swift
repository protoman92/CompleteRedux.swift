//
//  Redux+Saga+Effects.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

public extension Redux.Saga.Effect {
  public typealias E = Redux.Saga.Effect
  typealias Call = Redux.Saga.CallEffect
  typealias Empty = Redux.Saga.EmptyEffect
  typealias Just = Redux.Saga.JustEffect
  typealias Put = Redux.Saga.PutEffect
  typealias Select = Redux.Saga.SelectEffect
  typealias TakeLatest = Redux.Saga.TakeLatestEffect
  
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
  
  /// Create a select effect.
  ///
  /// - Parameter selector: The state selector function.
  /// - Returns: An Effect instance.
  public static func select(_ selector: @escaping (State) -> R) -> E<State, R> {
    return Select(selector)
  }
  
  /// Create a put effect.
  ///
  /// - Parameters:
  ///   - param: The parameter to put into redux state.
  ///   - actionCreator: The action creator function.
  /// - Returns: An Effect instance.
  public static func put<P>(
    _ param: E<State, P>,
    actionCreator: @escaping (P) -> ReduxActionType) -> E<State, Any>
  {
    return Put(param, actionCreator)
  }
  
  /// Create a call effect with an Observable.
  ///
  /// - Parameters:
  ///   - param: The parameter to call with.
  ///   - callCreator: The call creator function.
  /// - Returns: An Effect instance.
  public static func call<P>(
    param: E<State, P>,
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
    param: E<State, P>,
    callCreator: @escaping (P, @escaping (Try<R>) -> Void) -> Void) -> E<State, R>
  {
    return call(param: param) {(param) in
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
  
  /// Create a take latest effect.
  ///
  /// - Parameters:
  ///   - actionType: The type of action to filter.
  ///   - paramExtractor: The param extractor function.
  ///   - effectCreator: The effect creator function.
  /// - Returns: An Effect instance.
  public static func takeLatest<Action, P>(
    actionType: Action.Type,
    paramExtractor: @escaping (Action) -> P?,
    effectCreator: @escaping (P) -> E<State, R>)
    -> E<State, R> where Action: ReduxActionType
  {
    return TakeLatest(actionType, paramExtractor, effectCreator)
  }
}
