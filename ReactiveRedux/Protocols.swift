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

/// This represents a Redux store that can dispatch actions to mutate internal
/// state and broadcast state updates to subscribers.
public protocol ReduxStoreType {
  
  /// The app-specific state type. For example:
  ///
  ///     struct State {
  ///       var counter: Int = 0
  ///       var user: User? = nil
  ///     }
  ///
  /// It is recommended to make the state immutable to avoid unintended side
  /// effects.
  associatedtype State
  
  /// Get the last state instance.
  var lastState: Redux.Store.LastState<State> { get }
  
  /// Dispatch an action and notify listeners.
  var dispatch: Redux.Store.Dispatch { get }
  
  /// Set up state callback so that every time a new state arrives, call the
  /// callback function.
  var subscribeState: Redux.Store.Subscribe<State> { get }
}

/// Objects that implement this protocol must have a read-write lock that
/// allows thread-safe reads/writes.
public protocol ReadWriteLockableType {

  /// The read-write lock object.
  var lock: ReadWriteLockType { get }
}

/// Implement this protocol to provide read-write lock capabilities.
public protocol ReadWriteLockType {
  
  /// Lock reads for safe property access.
  ///
  /// - Parameter force: Deadlock if not possible to acquire lock.
  /// - Returns: Anything that indicates the success of lock acquisition.
  @discardableResult
  func lockRead(force: Bool) -> Bool
  
  /// Lock writes for safe property modification.
  ///
  /// - Parameter force: Deadlock if not possible to acquire lock.
  /// - Returns: Anything that indicates the success of lock acquisition.
  @discardableResult
  func lockWrite(force: Bool) -> Bool
  
  /// Release the lock.
  ///
  /// - Returns: Anything that indicates the success of lock acquisition.
  @discardableResult
  func unlock() -> Bool
}

public extension ReadWriteLockableType {
  
  /// Access some property in a thread-safe manner.
  func access<T>(_ accessor: () throws -> T) rethrows -> T? {
    if self.lock.lockRead(force: false) {
      defer {self.lock.unlock()}
      return try accessor()
    }
    
    return nil
  }
  
  /// Modify some property in a thread-safe manner.
  func modify(_ modifier: () throws -> Void) rethrows {
    if self.lock.lockWrite(force: false) {
      defer {self.lock.unlock()}
      try modifier()
    }
  }
}
