//
//  Redux+Saga+Unwrap.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/12/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import SwiftFP

extension ReduxSagaEffectConvertibleType where R: OptionalType {

  /// If the output values are optional, unwrap them if possible, otherwise
  /// emit nothing.
  ///
  /// - Returns: An Effect instance.
  public func unwrap() -> Redux.Saga.Effect<State, R.Value> {
    return self.filter({$0.isSome}).map({$0.value!})
  }
}
