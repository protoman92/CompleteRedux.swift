//
//  Redux+Saga+Call.swift
//  SwiftRedux
//
//  Created by Hai Pham on 12/9/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Effect whose output performs some asynchronous work and then emit the
/// result.
public final class CallEffect<State, P, R>: SagaEffect<State, R> {
  private let _param: SagaEffect<State, P>
  private let _callCreator: (P) -> Observable<R>
  
  public init(_ param: SagaEffect<State, P>,
              _ callCreator: @escaping (P) -> Observable<R>) {
    self._param = param
    self._callCreator = callCreator
  }
  
  override public func invoke(_ input: SagaInput<State>) -> SagaOutput<R> {
    return self._param.invoke(input).flatMap(self._callCreator)
  }
}

extension SagaEffectConvertibleType {

  /// Invoke a call effect on the current effect.
  ///
  /// - Parameter callCreator: A call creator function.
  /// - Returns: An Effect instance.
  public func call<R2>(_ callCreator: @escaping (R) -> Observable<R2>)
    -> SagaEffect<State, R2>
  {
    return self.asEffect().transform(with: {
      SagaEffect<State, R>.call(with: $0, callCreator: callCreator)
    })
  }
  
  /// Invoke a call effect on the current effect.
  ///
  /// - Parameter callCreator: A call creator function.
  /// - Returns: An Effect instance.
  public func call<R2>(
    _ callCreator: @escaping (R, @escaping (Try<R2>) -> Void) -> Void)
    -> SagaEffect<State, R2>
  {
    return self.asEffect().transform(with: {
      SagaEffect<State, R>.call(with: $0, callCreator: callCreator)
    })
  }
  
  /// Invoke a call effect on the current effect.
  ///
  /// - Parameter callCreator: A call creator function.
  /// - Returns: An Effect instance.
  public func call<R2>(
    _ callCreator: @escaping (R, @escaping (R2?, Error?) -> Void) -> Void)
    -> SagaEffect<State, R2>
  {
    return self.asEffect().transform(with: {
      SagaEffect.call(with: $0, callCreator: callCreator)
    })
  }
}
