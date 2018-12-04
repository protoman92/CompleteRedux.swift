//
//  Redux+Saga+Effects.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

public extension Redux.Saga {
  public final class Effects {
    public typealias Effect = Redux.Saga.Effect
    typealias Call = Redux.Saga.CallEffect
    typealias Empty = Redux.Saga.EmptyEffect
    typealias Just = Redux.Saga.JustEffect
    typealias Put = Redux.Saga.PutEffect
    typealias Select = Redux.Saga.SelectEffect
    typealias TakeLatest = Redux.Saga.TakeLatestEffect
    
    public static func empty<State, R>() -> Effect<State, R> {
      return Empty()
    }
    
    public static func just<State, R>(
      _ value: R, forState type: State.Type) -> Effect<State, R>
    {
      return Just(value)
    }
    
    public static func select<State, R>(
      selector: @escaping (State) -> R) -> Effect<State, R>
    {
      return SelectEffect(selector)
    }
    
    public static func put<State, P>(
      paramEffect: Effect<State, P>,
      actionCreator: @escaping (P) -> ReduxActionType) -> Effect<State, Any>
    {
      return Put(paramEffect, actionCreator)
    }
    
    public static func callWithObservable<State, P, R>(
      paramEffect: Effect<State, P>,
      callCreator: @escaping (P) -> Observable<R>) -> Effect<State, R>
    {
      return Call(paramEffect, callCreator)
    }
    
    public static func callWithCallback<State, P, R>(
      paramEffect: Effect<State, P>,
      callCreator: @escaping (P, (Try<R>) -> Void) -> Void) -> Effect<State, R>
    {
      return callWithObservable(paramEffect: paramEffect) {(param) in
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
    
    public static func takeLatest<State, Action, P, R>(
      actionType: Action.Type,
      paramType: P.Type,
      paramExtractor: @escaping (Action) -> P?,
      effectCreator: @escaping (P) -> Effect<State, R>)
      -> Effect<State, R> where Action: ReduxActionType
    {
      return TakeLatest(actionType, paramType, paramExtractor, effectCreator)
    }
  }
}
