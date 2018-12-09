//
//  Redux+Saga+CatchError.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/9/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

extension Redux.Saga {

  /// Effect whose output catches error from another output and return some
  /// fallback effect.
  final class CatchErrorEffect<State, R>: Effect<State, R> {
    private let _source: Effect<State, R>
    private let _catcher: (Swift.Error) throws -> Effect<State, R>
    
    init(_ source: Effect<State, R>,
         _ catcher: @escaping (Swift.Error) throws -> Effect<State, R>) {
      self._source = source
      self._catcher = catcher
    }
    
    override func invoke(_ input: Input<State>) -> Output<R> {
      return self._source.invoke(input)
        .catchError({try self._catcher($0).invoke(input)})
    }
  }
}

extension ReduxSagaEffectType {
  
  /// Invoke a catch error effect on the current effect.
  ///
  /// - Parameter catcher: The error catcher function.
  /// - Returns: An Effect instance.
  public func catchError(
    _ catcher: @escaping (Swift.Error) throws -> Redux.Saga.Effect<State, R>)
    -> Redux.Saga.Effect<State, R>
  {
    return self.asEffect().asInput(for: {.catchError($0, catcher: catcher)})
  }
  
  /// Convenience method to catch error and return a fallback value instead of
  /// an effect.
  ///
  /// - Parameter catcher: The error catcher function.
  /// - Returns: An Effect instance.
  public func catchError(_ catcher: @escaping (Swift.Error) throws -> R)
    -> Redux.Saga.Effect<State, R>
  {
    return self.catchError({.just(try catcher($0))})
  }
}
