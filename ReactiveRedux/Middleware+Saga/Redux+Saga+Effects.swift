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
    
    public static func empty<State, R>() -> Effect<State, R> {
      return Empty()
    }
  }
}
