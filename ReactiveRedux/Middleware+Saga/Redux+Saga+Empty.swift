//
//  Redux+Saga+Empty.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/9/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

extension Redux.Saga {
  
  /// Empty effect whose output does not stream anything.
  public final class EmptyEffect<State, R>: Effect<State, R> {
    override public func invoke(_ input: Input<State>) -> Output<R> {
      return Output(.empty(), {_ in})
    }
  }
}
