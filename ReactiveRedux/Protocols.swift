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

/// This represents a Redux store that stream state updates.
public protocol ReduxStoreType {
  associatedtype State
  
  /// Get the last state instance.
  var lastState: Redux.Store.LastState<State> { get }
  
  /// Dispatch an action and notify listeners.
  var dispatch: Redux.Store.Dispatch { get }
  
  /// Set up state callback so that every time a new state arrives, call the
  /// callback function.
  var subscribeState: Redux.Store.Subscribe<State> { get }
}
