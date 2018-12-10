//
//  Redux+Saga+Effect.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

extension Redux.Saga {
  
  /// Transformer function that takes an effect as the input and produces
  /// another effect.
  public typealias EffectTransformer<State, R1, R2> =
    (Effect<State, R1>) -> Effect<State, R2>
  
  /// Transformer function that transforms one effect into another, with both
  /// effects having the same output value type.
  public typealias MonoEffectTransformer<State, R> = EffectTransformer<State, R, R>

  /// Base class for a side effect that is able to produce an output stream
  /// based on the current state of the Redux store. Subclasses must override
  /// the main invocation method to customize the saga output.
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
