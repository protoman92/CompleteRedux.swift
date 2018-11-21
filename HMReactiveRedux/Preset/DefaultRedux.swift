//
//  DefaultRedux.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/21/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

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
