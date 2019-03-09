//
//  Redux+Saga+CatchError.swift
//  SwiftRedux
//
//  Created by Hai Pham on 12/9/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Effect whose output catches error from another effect's output and return
/// some fallback effect.
public final class CatchErrorEffect<State, R>: SagaEffect<State, R> {
  private let _source: SagaEffect<State, R>
  private let _catcher: (Swift.Error) throws -> SagaEffect<State, R>
  
  init(_ source: SagaEffect<State, R>,
       _ catcher: @escaping (Swift.Error) throws -> SagaEffect<State, R>) {
    self._source = source
    self._catcher = catcher
  }
  
  override public func invoke(_ input: SagaInput<State>) -> SagaOutput<R> {
    return self._source.invoke(input).catchError({try self._catcher($0).invoke(input)})
  }
}

extension SagaEffectConvertibleType {
  
  /// Invoke a catch error effect on the current effect.
  ///
  /// - Parameter catcher: The error catcher function.
  /// - Returns: An Effect instance.
  public func catchError(
    _ catcher: @escaping (Swift.Error) throws -> SagaEffect<State, R>)
    -> SagaEffect<State, R>
  {
    return self.asEffect().transform(with: {.catchError($0, catcher: catcher)})
  }
  
  /// Convenience method to catch error and return a fallback value instead of
  /// an effect.
  ///
  /// - Parameter catcher: The error catcher function.
  /// - Returns: An Effect instance.
  public func catchError(_ catcher: @escaping (Swift.Error) throws -> R)
    -> SagaEffect<State, R>
  {
    return self.catchError({.just(try catcher($0))})
  }
}
