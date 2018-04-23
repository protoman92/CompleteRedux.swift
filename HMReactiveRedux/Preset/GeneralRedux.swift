//
//  GeneralRedux.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 23/11/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

/// General Redux actions that are not tied to any specific app/implementation.
/// We can use these generic actions as building blocks for app-specific redux
/// deployments.
public final class GeneralReduxAction {}

/// General Redux reducer that is not tied to a specifiec app/implementation.
public final class GeneralReduxReducer {
  public static func generalReducer(_ state: TreeState<Any>,
                                    _ action: ReduxActionType) -> TreeState<Any> {
    switch action {
    case let action as Global.Action:
      return Global.globalReducer(state, action)

    case let action as Error.Display:
      return Error.displayReducer(state, action)

    case let action as Progress.Display:
      return Progress.displayReducer(state, action)

    default:
      #if DEBUG
      fatalError("Unhandled action: \(action)")
      #else
      return state
      #endif
    }
  }
}
