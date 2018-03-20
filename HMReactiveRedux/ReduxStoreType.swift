//
//  ReduxStoreType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 17/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// This represents a Redux store that can dispatch events.
public protocol ReduxStoreType {
  typealias Action = ReduxActionType

  /// Dispatch some actions and notify listeners.
  ///
  /// - Parameter actions: A Sequence of Action.
  func dispatch<S>(_ actions: S) where S: Sequence, S.Element == Action
}

public extension ReduxStoreType {
  
  /// Convenience method to dispatch some actions.
  ///
  /// - Parameter actions: A Sequence of Action.
  public func dispatch<S>(_ actions: S) where S: Sequence, S.Element: Action {
    let mapped: [Action] = actions.map({$0})
    dispatch(mapped)
  }
  
  /// Convenience method to dispatch some actions.
  ///
  /// - Parameter actions: Varargs of Redux actions.
  public func dispatch(_ actions: Action...) {
    dispatch(actions)
  }
}
