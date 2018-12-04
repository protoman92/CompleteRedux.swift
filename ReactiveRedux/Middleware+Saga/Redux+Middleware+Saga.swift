//
//  Redux+Middleware+Saga.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux.Middleware {
  public final class Saga {
    public struct Provider<State>: ReduxMiddlewareProviderType {
      private let effects: [Redux.Saga.Effect<State, Any>]
      
      public init<S>(effects: S) where
        S: Sequence, S.Element == Redux.Saga.Effect<State, Any>
      {
        self.effects = Array(effects)
      }
      
      public var middleware: Middleware<State> {
        return {input in
          {wrapper in
            let lastState = input.lastState
            let sagaInput = Redux.Saga.Input(lastState, wrapper)
            let sagaOutputs = self.effects.map({$0.invoke(sagaInput)})
            let newWrapperId = "\(wrapper.identifier)-saga"
            sagaOutputs.forEach({$0.subscribe({_ in})})
            
            return Redux.Store.DispatchWrapper(newWrapperId) {action in
              wrapper.dispatch(action)
              sagaOutputs.forEach({$0.onAction(action)})
            }
          }
        }
      }
    }
  }
}
