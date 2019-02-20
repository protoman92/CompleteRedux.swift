//
//  Redux+Preset.swift
//  SwiftRedux
//
//  Created by Hai Pham on 11/21/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux {

  /// Top-level namespace for presets.
  public final class Preset {
    init() {}

    /// Convenience enum that contains default actions.
    public enum Action: ReduxActionType {

      /// Does nothing.
      case noop
    }
    
    /// Convenience class that contains default reducer.
    public final class Reducer {
      init() {}

      /// Reducer for preset actions.
      ///
      /// - Parameters:
      ///   - state: A State instance.
      ///   - action: A preset Action instance.
      /// - Returns: A State instance.
      public static func reduce<S>(_ state: S, _ action: Action) -> S {
        switch action {
        case .noop: return state
        }
      }
    }
  }
}
