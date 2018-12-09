//
//  Redux+Saga+Sequentialize.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/9/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

extension Redux.Saga {
  
  /// Effect whose output is the result of sequentializing the outputs of two
  /// effects. Use this effect to make sure one effect happens after another.
  final class SequentializeEffect<E1, E2, U>: Effect<E2.State, U> where
    E1: ReduxSagaEffectType,
    E2: ReduxSagaEffectType,
    E1.State == E2.State
  {
    private let effect1: E1
    private let effect2: E2
    private let combineFunc: (E1.R, E2.R) throws -> U
    
    init(_ effect1: E1,
         _ effect2: E2,
         _ combineFunc: @escaping (E1.R, E2.R) throws -> U) {
      self.effect1 = effect1
      self.effect2 = effect2
      self.combineFunc = combineFunc
    }
    
    override func invoke(_ input: Input<State>) -> Output<U> {
      return self.effect1.invoke(input).flatMap({result1 in
        self.effect2.invoke(input).map({try self.combineFunc(result1, $0)})})
    }
  }
}

extension ReduxSagaEffectType {
  
  /// Trigger another effect in sequence and combining emissions with a
  /// selector function.
  ///
  /// - Parameters:
  ///   - effect2: An Effect instance.
  ///   - selector: The selector function.
  /// - Returns: An Effect instance.
  public func then<R2, U>(
    _ effect2: Redux.Saga.Effect<State, R2>,
    selector: @escaping (R, R2) throws -> U)
    -> Redux.Saga.Effect<State, U>
  {
    return self.asInput(for: {.sequentialize($0, effect2, selector: selector)})
  }
  
  /// Trigger another event and ignore emission from this effect.
  ///
  /// - Parameter effect2: An Effect instance.
  /// - Returns: An Effect instance.
  public func then<R2>(_ effect2: Redux.Saga.Effect<State, R2>)
    -> Redux.Saga.Effect<State, R2>
  {
    return self.then(effect2, selector: {$1})
  }
  
  /// Convenience function to change emissions to another static value.
  ///
  /// - Parameter value: The value to change to.
  /// - Returns: An Effect instance.
  public func then<R2>(_ value: R2) -> Redux.Saga.Effect<State, R2> {
    return self.then(.just(value))
  }
}
