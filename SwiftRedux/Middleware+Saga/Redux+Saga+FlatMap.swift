//
//  Redux+Saga+FlatMap.swift
//  SwiftRedux
//
//  Created by Viethai Pham on 11/6/19.
//  Copyright © 2019 Swiften. All rights reserved.
//

/// Effect whose output flattens another output produced by another effect.
public class FlatMapEffect<R, E>: SagaEffect<E.R> where E: SagaEffectConvertibleType {
  fileprivate let source: SagaEffect<R>
  fileprivate let creator: (R) throws -> E
  
  init(_ source: SagaEffect<R>, _ creator: @escaping (R) throws -> E) {
    self.source = source
    self.creator = creator
  }
  
  override public func invoke(_ input: SagaInput) -> SagaOutput<E.R> {
    return self.source.invoke(input)
      .flatMap({try self.creator($0).asEffect().invoke(input)})
  }
}

/// Effect whose output flattens the latest output produced by another effect.
public final class SwitchMapEffect<R, E>: FlatMapEffect<R, E> where E: SagaEffectConvertibleType {
  override public func invoke(_ input: SagaInput) -> SagaOutput<E.R> {
    return self.source.invoke(input)
      .switchMap({try self.creator($0).asEffect().invoke(input)})
  }
}

extension SagaEffectConvertibleType {
  
  /// Invoke a FlatMapEffect with mode every.
  ///
  /// - Parameter fn: The effect creator function.
  /// - Returns: A SagaEffect instance.
  public func flatMap<E>(_ fn: @escaping (R) throws -> E) -> SagaEffect<E.R> where
    E: SagaEffectConvertibleType
  {
    return self.transform(with: {FlatMapEffect($0, fn)})
  }
  
  /// Invoke a FlatMapEffect with mode latest.
  ///
  /// - Parameter fn: The effect creator function.
  /// - Returns: A SagaEffect instance.
  public func switchMap<E>(_ fn: @escaping (R) throws -> E) -> SagaEffect<E.R> where
    E: SagaEffectConvertibleType
  {
    return self.transform(with: {SwitchMapEffect($0, fn)})
  }
}
