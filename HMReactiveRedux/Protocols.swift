//
//  Protocols.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/21/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import RxSwift
import SwiftFP

/// Classes that implement this protocol should represent possible actions that
/// can be passed to a reducer.
///
/// Ideally, an app should define an enum for this purpose, so that it can pass
/// data as enum arguments.
public protocol ReduxActionType {}

/// Represent a reducer that takes an action and a state to produce another
/// state.
public typealias ReduxReducer<State> = (State, ReduxActionType) -> State

/// Typealias for a dispatch function.
public typealias ReduxDispatch = (ReduxActionType) -> Void

/// This represents a Redux store that can dispatch events.
public protocol ReduxStoreType {
  typealias Action = ReduxActionType
  typealias Cancellable = () -> Void
  associatedtype State
  
  /// Get the last state instance.
  var lastState: Try<State> { get }
  
  /// Dispatch an action and notify listeners.
  ///
  /// - Parameter action: An Action instance.
  func dispatch(_ action: Action)
  
  /// Set up state callback so that every time a new state arrives, call the
  /// callback function.
  ///
  /// - Parameter callback: State callback function.
  /// - Returns: Cancel function to invalidate the callback
  func subscribeState(callback: @escaping (State) -> Void) -> Cancellable
}

public extension ReduxStoreType {
  
  /// Dispatch some actions and notify listeners.
  ///
  /// - Parameter actions: A Sequence of Action.
  public func dispatch<S>(_ actions: S) where S: Sequence, S.Element == Action {
    actions.forEach({self.dispatch($0)})
  }
}
