//
//  DefaultRedux.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 11/21/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Default Redux convenience class that contains basic reusable actions..
public final class DefaultRedux {
  public enum Action: ReduxActionType {
    case noop
  }
  
  public final class Reducer {
    public static func reduce<State>(_ state: State, _ action: Action) -> State? {
      switch action {
      case .noop:
        return state
      }
    }
  }
}
