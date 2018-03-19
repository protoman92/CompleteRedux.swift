//
//  PingActionCheckerType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 19/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

#if DEBUG
  /// If the build is in debug, use this to check a ping action's state (i.e.
  /// actions used to dispatch events, but whose state should not be persisted
  /// to the global state - these actions should have a counter action that
  /// must be dispatched right after to clear the relevant state values).
  public protocol PingActionCheckerType {
    
    /// Check whether the relevant state values have been cleared.
    ///
    /// - Parameter action: A ReduxActionType instance.
    /// - Returns: A Bool value.    
    func checkPingActionCleared(_ action: ReduxActionType) -> Bool
  }
#endif
