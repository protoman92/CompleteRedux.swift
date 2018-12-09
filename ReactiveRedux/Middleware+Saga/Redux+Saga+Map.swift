//
//  Redux+Saga+Map.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/9/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

extension Redux.Saga {
  
  /// Effect whose output maps the value from that of a source to another value.
  final class MapEffect<E1, R2>: Effect<E1.State, R2> where E1: ReduxSagaEffectType {
    private let source: E1
    private let mapper: (E1.R) throws -> R2
    
    init(_ source: E1, _ mapper: @escaping (E1.R) throws -> R2) {
      self.source = source
      self.mapper = mapper
    }
    
    override func invoke(_ input: Input<E1.State>) -> Output<R2> {
      return self.source.invoke(input).map(self.mapper)
    }
  }
}

extension ReduxSagaEffectType {
    
  /// Invoke a map effect on the current effect.
  ///
  /// - Parameter mapper: The mapper function.
  /// - Returns: An Effect instance.
  public func map<R2>(_ mapper: @escaping (R) throws -> R2)
    -> Redux.Saga.Effect<State, R2>
  {
    return self.asInput(for: {.map($0, withMapper: mapper)})
  }
}
