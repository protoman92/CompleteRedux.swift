//
//  Redux+Saga+Map.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/9/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

extension Redux.Saga {
  
  /// Effect whose output maps the value emissions from that of a source to
  /// other values of possible different types.
  public final class MapEffect<State, R1, R2>: Effect<State, R2> {
    private let source: Redux.Saga.Effect<State, R1>
    private let mapper: (R1) throws -> R2
    
    init(_ source: Redux.Saga.Effect<State, R1>,
         _ mapper: @escaping (R1) throws -> R2) {
      self.source = source
      self.mapper = mapper
    }
    
    override public func invoke(_ input: Input<State>) -> Output<R2> {
      return self.source.invoke(input).map(self.mapper)
    }
  }
}

extension ReduxSagaEffectConvertibleType {
    
  /// Invoke a map effect on the current effect.
  ///
  /// - Parameter mapper: The mapper function.
  /// - Returns: An Effect instance.
  public func map<R2>(_ mapper: @escaping (R) throws -> R2)
    -> Redux.Saga.Effect<State, R2>
  {
    return self.asEffect()
      .transform(with: {Redux.Saga.Effect.map($0, withMapper: mapper)})
  }
}
