//
//  Redux+Saga+Effects.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux.Saga {
  public final class Effects {
    public typealias Effect = Redux.Saga.Effect
    typealias Empty = Redux.Saga.EmptyEffect
    typealias Put = Redux.Saga.PutEffect
    typealias Select = Redux.Saga.SelectEffect
    typealias TakeLatest = Redux.Saga.TakeLatestEffect
    
    public static func empty<State, R>() -> Effect<State, R> {
      return Empty()
    }
    
    public static func select<State, R>(
      selector: @escaping (State) -> R) -> Effect<State, R> {
      return SelectEffect(selector)
    }
    
    public static func put<State, P>(
      dataEffect: Effect<State, P>,
      actionCreator: @escaping (P) -> ReduxActionType) -> Effect<State, Any>
    {
      return Put(dataEffect, actionCreator)
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
