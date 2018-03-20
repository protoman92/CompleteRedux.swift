//
//  ReduxStoreType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 17/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

/// This represents a Redux store that can dispatch events.
public protocol ReduxStoreType {
  typealias Action = ReduxActionType

  /// Dispatch a single action.
  ///
  /// - Parameter action: An Action instance.
  func dispatch(_ action: Action)

  /// Dispatch some actions and notify listeners.
  ///
  /// - Parameter actions: A Sequence of Action.
  func dispatchAll<S>(_ actions: S) where S: Sequence, S.Element == Action
}

public extension ReduxStoreType {
  
  /// Convenience method to dispatch some actions.
  ///
  /// - Parameter actions: A Sequence of Action.
  public func dispatchAll<S>(_ actions: S) where S: Sequence, S.Element: Action {
    let mapped: [Action] = actions.map({$0})
    dispatchAll(mapped)
  }
  
  /// Convenience method to dispatch some actions.
  ///
  /// - Parameter actions: Varargs of Redux actions.
  public func dispatchAll(_ actions: Action...) {
    dispatchAll(actions)
  }
}
