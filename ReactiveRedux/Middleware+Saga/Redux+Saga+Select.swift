//
//  Redux+Saga+Select.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/9/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

extension Redux.Saga {
  
  /// Effect whose output selects some value from a redux store's managed state.
  /// The extracted value can then be fed to other effects that require params.
  final class SelectEffect<State, R>: Effect<State, R> {
    private let _selector: (State) -> R
    
    init(_ selector: @escaping (State) -> R) {
      self._selector = selector
    }
    
    override func invoke(_ input: Input<State>) -> Output<R> {
      return Output(.just(self._selector(input.lastState())), {_ in})
    }
  }
}
