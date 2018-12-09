//
//  Redux+Saga+Effect.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

extension Redux.Saga {

  /// Base class for a side effect. Subclasses must override the main invocation
  /// method to customize the saga output.
  public class Effect<State, R>: ReduxSagaEffectType {
    init() {}
    
    public func invoke(_ input: Input<State>) -> Output<R> {
      return Output(.error(Redux.Saga.Error.unimplemented), {_ in})
    }
    
    public func asEffect() -> Effect<State, R> {
      return self
    }
  }
}
