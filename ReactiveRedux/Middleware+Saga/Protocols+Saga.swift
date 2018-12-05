//
//  Protocols+Saga.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/5/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Implement this protocol to represent a Redux saga effect.
public protocol ReduxSagaEffectType {
  associatedtype State
  associatedtype R
  
  func invoke(_ input: Redux.Saga.Input<State>) -> Redux.Saga.Output<R>
}

extension ReduxSagaEffectType {
  func invoke(withState state: State, dispatch: @escaping Redux.Store.Dispatch)
    -> Redux.Saga.Output<R>
  {
    return self.invoke(Redux.Saga.Input({state}, dispatch))
  }
}

/// Implement this protocol to represent a take effect (e.g. take latest or
/// take every).
public protocol ReduxSagaTakeEffectType: ReduxSagaEffectType {
  associatedtype Action: ReduxActionType
  associatedtype P
  
  init(_ actionType: Action.Type,
       _ paramExtractor: @escaping (Action) -> P?,
       _ outputCreator: @escaping (P) -> Redux.Saga.Effect<State, R>)
}
