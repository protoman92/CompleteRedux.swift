//
//  Redux+Saga+Just.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/9/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

extension Redux.Saga {

  /// Effect whose output simply emits some specified element.
  public final class JustEffect<State, R>: Effect<State, R> {
    private let value: R
    
    init(_ value: R) {
      self.value = value
    }
    
    override public func invoke(_ input: Input<State>) -> Output<R> {
      return Output(.just(self.value), {_ in})
    }
  }
}
