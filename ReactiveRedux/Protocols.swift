//
//  Protocols.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 11/21/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

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

/// Unique id for a subscriber.
public typealias ReduxSubscriberId = String

/// Callback for state subscriptions.
public typealias ReduxCallback<State> = (State) -> Void

/// Typealias for the dispatch function.
public typealias ReduxDispatch = (ReduxActionType) -> Void

/// Typealias for the state subscribe function. Pass in the subscriber id and
/// callback function.
public typealias ReduxSubscribe<State> = (
  ReduxSubscriberId,
  @escaping ReduxCallback<State>) -> ReduxSubscription

/// This represents a Redux store that stream state updates.
public protocol ReduxStoreType {
  associatedtype State
  
  /// Get the last state instance.
  var lastState: State { get }
  
  /// Dispatch an action and notify listeners.
  var dispatch: ReduxDispatch { get }
  
  /// Set up state callback so that every time a new state arrives, call the
  /// callback function.
  var subscribeState: ReduxSubscribe<State> { get }
}

public extension ReduxStoreType {
  
  /// Dispatch some actions and notify listeners.
  ///
  /// - Parameter actions: A Sequence of Action.
  public func dispatch<S>(_ actions: S) where S: Sequence, S.Element == ReduxActionType {
    actions.forEach({self.dispatch($0)})
  }
}
