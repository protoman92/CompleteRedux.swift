//
//  Redux+Preset.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 11/21/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux {

  /// Top-level namespace for presets.
  public final class Preset {

    /// Default Redux convenience class that contains basic reusable actions..
    public enum Action: ReduxActionType {
      case noop
    }
    
    public final class Reducer {
      public static func reduce<S>(_ state: S, _ action: Action) -> S {
        switch action {
        case .noop:
          return state
        }
      }
    }
  }
}
