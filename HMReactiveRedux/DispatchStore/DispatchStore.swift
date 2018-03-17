//
//  DispatchStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 17/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import SwiftFP

/// Use this for state value callback.
public typealias ReduxCallback<Value> = (Try<Value>) -> Void

/// This is a simple dispatch-based Redux store with no rx.
public final class DispatchStore<Value> {
  public typealias State = TreeState<Value>

  /// Create a new dispatch store.
  ///
  /// - Parameters:
  ///   - initialState: The initial state.
  ///   - reducer: The main reducer.
  /// - Returns: A DispatchStore instance.
  public static func createInstance(_ initialState: State,
                                    _ reducer: @escaping ReduxReducer<State>)
    -> DispatchStore<Value>
  {
    return DispatchStore(initialState, reducer)
  }

  fileprivate let mutex: NSLock
  fileprivate let reducer: ReduxReducer<State>
  fileprivate var callbacks: [String : [String : ReduxCallback<Value>]]
  fileprivate var state: State

  fileprivate init(_ initialState: State,
                   _ reducer: @escaping ReduxReducer<State>) {
    self.reducer = reducer
    callbacks = [:]
    mutex = NSLock()
    state = initialState
  }

  /// The state is immutable anyway, so no harm exposing it.
  public func lastState() -> State {
    mutex.lock()
    defer { mutex.unlock() }
    return state
  }

  public func lastValue(_ identifier: String) -> Try<Value> {
    mutex.lock()
    defer { mutex.unlock() }
    return state.stateValue(identifier)
  }

  /// Register a callback at a particular path.
  ///
  /// - Parameters:
  ///   - id: The registrant's id.
  ///   - path: The path to listen to.
  ///   - callback: A ReduxCallback instance.
  public func register(_ id: String,
                       _ path: String,
                       _ callback: @escaping ReduxCallback<Value>) {
    mutex.lock()
    defer { mutex.unlock() }
    var pathCB = callbacks[path] ?? [:]
    pathCB[id] = callback
    callbacks[path] = pathCB

    /// Relay the last event.
    let value = state.stateValue(path)
    callback(value)
  }

  /// Unregister callback at a path.
  ///
  /// - Parameters:
  ///   - id: The registrant's id.
  ///   - path: The path to unregister from.
  /// - Returns: A Bool value indicating whether there was a callback.
  @discardableResult
  public func unregister(_ id: String, _ path: String) -> Bool {
    mutex.lock()
    defer { mutex.unlock() }

    if var pathCB = callbacks[path] {
      if pathCB.removeValue(forKey: id) != nil {
        callbacks[path] = pathCB
        return true
      }
    }

    return false
  }

  @discardableResult
  private func _unregisterAll<S>(_ ids: S) -> Int where S: Sequence, S.Iterator.Element == String {
    var newCallbacks = [String : [String : ReduxCallback<Value>]]()

    for (key, value) in callbacks {
      var pathCBs = [String : ReduxCallback<Value>]()

      for (key1, value1) in value where !ids.contains(key1) {
        pathCBs[key1] = value1
      }

      newCallbacks[key] = pathCBs
    }

    let callbackCount: ([String : [String : ReduxCallback<Value>]]) -> Int = {
      return $0.reduce(0, {$0 + $1.value.count})
    }

    let removed = callbackCount(callbacks) - callbackCount(newCallbacks)
    self.callbacks = newCallbacks
    return removed
  }

  /// Unregister all paths for some ids.
  ///
  /// - Parameter ids: The registrant's ids.
  /// - Returns: An Int value indicating the number of removed callbacks.
  public func unregisterAll<S>(_ ids: S) -> Int where S: Sequence, S.Iterator.Element == String {
    mutex.lock()
    defer { mutex.unlock() }
    return _unregisterAll(ids)
  }

  /// Convenience method to unregister all paths for some ids.
  ///
  /// - Parameter ids: Varargs of ids.
  /// - Returns: An Int value indicating the number of removed callbacks.
  public func unregisterAll(_ ids: String...) -> Int {
    return unregisterAll(ids)
  }
}

extension DispatchStore: ReduxStoreType {

  /// Dispatch an action and notify all listeners.
  ///
  /// - Parameter action: A ReduxActionType.
  public func dispatch(_ action: ReduxActionType) {
    mutex.lock()
    defer { mutex.unlock() }
    let state = reducer(self.state, action)
    self.state = state

    for (key, value) in callbacks {
      for (_, callback) in value {
        callback(state.stateValue(key))
      }
    }
  }
}
