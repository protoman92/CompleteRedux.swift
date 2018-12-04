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
    typealias Select = Redux.Saga.SelectEffect
    
    public static func empty<State, R>() -> Effect<State, R> {
      return Empty()
    }
    
    public static func select<State, R>(
      selector: @escaping (State) -> R) -> Effect<State, R> {
      return SelectEffect(selector)
    }
  }
}
