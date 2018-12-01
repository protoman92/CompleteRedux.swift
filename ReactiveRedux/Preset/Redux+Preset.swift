//
//  Redux+Preset.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 11/21/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux {

  /// Default Redux convenience class that contains basic reusable actions..
  public enum DefaultAction: ReduxActionType {
    case noop
  }
    
  public final class DefaultReducer {
    public static func reduce<State>(_ state: State, _ action: DefaultAction) -> State? {
      switch action {
      case .noop:
        return state
      }
    }
  }
}
