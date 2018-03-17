//
//  GeneralRedux+Error.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 20/1/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension GeneralReduxAction {

  /// Error-related actions.
  public final class Error {
    public enum Display: ReduxPingActionType {
      case updateShowError(Swift.Error?)

      public var pingValuePath: String {
        return Display.errorPath
      }

      public static var path: String {
        return "error.display"
      }

      public static var errorPath: String {
        return "\(path).error"
      }
    }
  }
}

public extension GeneralReduxReducer {

  /// Error reducer.
  public final class Error {
    public typealias Display = GeneralReduxAction.Error.Display

    public static func displayReducer(_ state: TreeState<Any>,
                                      _ action: Display) -> TreeState<Any> {
      switch action {
      case .updateShowError(let error):
        return state.updateValue(Display.errorPath, error)
      }
    }
  }
}
