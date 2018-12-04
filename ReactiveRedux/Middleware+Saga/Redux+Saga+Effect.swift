//
//  Redux+Saga+Effect.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

public extension Redux.Saga {
  public class Effect<State, R> {
    func invoke(_ input: Input<State>) -> Output<R> {
      return Output(.error(Redux.Saga.Error.unimplemented), {_ in})
    }
  }
  
  final class EmptyEffect<State, R>: Effect<State, R> {
    override func invoke(_ input: Input<State>) -> Output<R> {
      return Output(.empty(), {_ in})
    }
  }
  
  final class SelectEffect<State, R>: Effect<State, R> {
    private let _selector: (State) -> R
    
    init(_ selector: @escaping (State) -> R) {
      self._selector = selector
    }
    
    override func invoke(_ input: Input<State>) -> Output<R> {
      return Output(.just(self._selector(input.lastState())), {_ in})
    }
  }
  
  final class PutEffect<State, P>: Effect<State, Any> {
    private let _actionCreator: (P) -> ReduxActionType
    private let _dataEffect: Effect<State, P>
    
    init(_ dataEffect: Effect<State, P>,
         _ actionCreator: @escaping (P) -> ReduxActionType) {
      self._actionCreator = actionCreator
      self._dataEffect = dataEffect
    }
    
    override func invoke(_ input: Input<State>) -> Output<Any> {
      return _dataEffect.invoke(input)
        .map(self._actionCreator)
        .map(input.dispatchWrapper.dispatch)
    }
  }
}
