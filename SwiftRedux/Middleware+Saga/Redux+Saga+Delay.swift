//
//  Redux+Saga+Delay.swift
//  SwiftRedux
//
//  Created by Hai Pham on 12/9/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import Foundation

extension Redux.Saga {

  /// Effect whose output delays emission by some period of time.
  public final class DelayEffect<State, R>: Effect<State, R> {
    private let sourceEffect: Effect<State, R>
    private let delayTime: TimeInterval
    private let dispatchQueue: DispatchQueue
    
    init(_ sourceEffect: Effect<State, R>,
         _ delayTime: TimeInterval,
         _ dispatchQueue: DispatchQueue) {
      self.sourceEffect = sourceEffect
      self.delayTime = delayTime
      self.dispatchQueue = dispatchQueue
    }
    
    override public func invoke(_ input: Input<State>) -> Output<R> {
      return self.sourceEffect.invoke(input).delay(
        bySeconds: self.delayTime,
        usingQueue: self.dispatchQueue)
    }
  }
}

extension ReduxSagaEffectConvertibleType {
  
  /// Invoke a delay effect on the current effect.
  ///
  /// - Parameters:
  ///   - sec: The time interval to delay by.
  ///   - queue: The queue to delay on.
  /// - Returns: An Effect instance.
  public func delay(
    bySeconds sec: TimeInterval,
    usingQueue queue: DispatchQueue = .global(qos: .default))
    -> Redux.Saga.Effect<State, R>
  {
    return self.asEffect()
      .transform(with: {.delay($0, bySeconds: sec, usingQueue: queue)})
  }
}
