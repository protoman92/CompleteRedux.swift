//
//  Redux+Preset.swift
//  SwiftRedux
//
//  Created by Hai Pham on 11/21/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Convenience enum that contains default actions.
public enum DefaultAction: ReduxActionType {

  /// Does nothing.
  case noop
}

/// Convenience class that contains default reducer.
public final class DefaultReducer {
  init() {}

  /// Reducer for preset actions.
  ///
  /// - Parameters:
  ///   - state: A State instance.
  ///   - action: A preset Action instance.
  /// - Returns: A State instance.
  public static func reduce<S>(_ state: S, _ action: DefaultAction) -> S {
    switch action {
    case .noop: return state
    }
  }
}
