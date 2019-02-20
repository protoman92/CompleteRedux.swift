//
//  Redux+Saga+Call.swift
//  SwiftRedux
//
//  Created by Hai Pham on 12/9/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

extension Redux.Saga {

  /// Effect whose output performs some asynchronous work and then emit the
  /// result.
  public final class CallEffect<State, P, R>: Effect<State, R> {
    private let _param: Redux.Saga.Effect<State, P>
    private let _callCreator: (P) -> Observable<R>
    
    public init(_ param: Redux.Saga.Effect<State, P>,
                _ callCreator: @escaping (P) -> Observable<R>) {
      self._param = param
      self._callCreator = callCreator
    }
    
    override public func invoke(_ input: Input<State>) -> Output<R> {
      return self._param.invoke(input).flatMap(self._callCreator)
    }
  }
}

extension ReduxSagaEffectConvertibleType {

  /// Invoke a call effect on the current effect.
  ///
  /// - Parameter callCreator: A call creator function.
  /// - Returns: An Effect instance.
  public func call<R2>(_ callCreator: @escaping (R) -> Observable<R2>)
    -> Redux.Saga.Effect<State, R2>
  {
    return self.asEffect().transform(with: {
      Redux.Saga.Effect<State, R>.call(with: $0, callCreator: callCreator)
    })
  }
  
  /// Invoke a call effect on the current effect.
  ///
  /// - Parameter callCreator: A call creator function.
  /// - Returns: An Effect instance.
  public func call<R2>(
    _ callCreator: @escaping (R, @escaping (Try<R2>) -> Void) -> Void)
    -> Redux.Saga.Effect<State, R2>
  {
    return self.asEffect().transform(with: {
      Redux.Saga.Effect<State, R>.call(with: $0, callCreator: callCreator)
    })
  }
  
  /// Invoke a call effect on the current effect.
  ///
  /// - Parameter callCreator: A call creator function.
  /// - Returns: An Effect instance.
  public func call<R2>(
    _ callCreator: @escaping (R, @escaping (R2?, Error?) -> Void) -> Void)
    -> Redux.Saga.Effect<State, R2>
  {
    return self.asEffect().transform(with: {
      Redux.Saga.Effect.call(with: $0, callCreator: callCreator)
    })
  }
}
