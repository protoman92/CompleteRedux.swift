//
//  DispatchStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 17/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import SwiftFP
import SwiftUtilities

fileprivate final class StrongReference<T> {
  fileprivate let value: T

  public init(_ value: T) {
    self.value = value
  }
}

/// This is a simple dispatch-based Redux store with no rx. It can be used to
/// build more specialized store implementations.
///
/// The state should be a value data structure to avoid external modifications.
public final class GenericDispatchStore<State> {
  fileprivate let dispatchQueue: DispatchQueue
  fileprivate let reducer: ReduxReducer<State>
  fileprivate var callbacks: [(String, [GenericReduxCallback<State>])]
  fileprivate var state: State
  
  #if DEBUG
    /// If in debug mode, keep track of last action to perform some custom
    /// asserts.
    fileprivate var lastAction: ReduxActionType?
  #endif

  init(_ initialState: State,
       _ reducer: @escaping ReduxReducer<State>,
       _ dispatchQueue: DispatchQueue) {
    self.dispatchQueue = dispatchQueue
    self.reducer = reducer
    callbacks = []
    state = initialState
  }
}

extension GenericDispatchStore: ReduxStoreType {
  public func dispatch(_ action: ReduxActionType) {
    let newState = reducer(self.state, action)
    let newStateRef = StrongReference(newState)
    let callbacks = self.callbacks
    self.state = newState
    
    #if DEBUG
      /// Check whether the ping action has been cleared, or else throw an error.
      if let state = newState as? PingActionCheckerType {
        if let action = self.lastAction, !state.checkPingActionCleared(action) {
          debugException("Must clear ping action \(action)")
        }
      } else {
        debugPrint("\(State.self) must implement \(PingActionCheckerType.self)")
      }
      
      self.lastAction = action
    #endif

    dispatchQueue.async {
      callbacks.forEach({$1.forEach({try? $0(newStateRef.value)})})
    }
  }
}

extension GenericDispatchStore: MinimalDispatchStoreType {
  public func lastState() -> State {
    return state
  }
  
  /// Unregister all callbacks for some ids.
  ///
  /// - Parameter ids: The registrant's ids.
  /// - Returns: An Int value indicating the number of removed callbacks.
  @discardableResult
  public func unregister<S>(_ ids: S) -> Int where S: Sequence, S.Iterator.Element == String {
    var unregistered = 0
    var newCallbacks = [(String, [GenericReduxCallback<State>])]()

    for (key, value) in callbacks {
      if !ids.contains(key) {
        newCallbacks.append((key, value))
      } else {
        unregistered += value.count
      }
    }

    self.callbacks = newCallbacks
    return unregistered
  }
}

extension GenericDispatchStore: GenericDispatchStoreType {
  public func register(_ id: String, _ callback: @escaping GenericReduxCallback<State>) {
    var didAdd = false

    for (ix, (key, value)) in callbacks.enumerated() {
      if key == id {
        var newValue = value
        newValue.append(callback)
        callbacks[ix] = (key, newValue)
        didAdd = true
        break
      }
    }

    if !didAdd {
      var newValue = [GenericReduxCallback<State>]()
      newValue.append(callback)
      callbacks.append((id, newValue))
    }
    
    let lastState = StrongReference(state)

    /// Relay the last event.
    dispatchQueue.async {try? callback(lastState.value)}
  }
}

public extension GenericDispatchStore {

  /// Create a generic dispatch store instance wrapper.
  ///
  /// - Parameters:
  ///   - initialState: The initial state.
  ///   - reducer: A ReduxReducer instance.
  ///   - dispatchQueue: A DispatchQueue instance.
  /// - Returns: A GenericDispatchStoreWrapper instance.
  public static func createInstance(_ initialState: State,
                                    _ reducer: @escaping ReduxReducer<State>,
                                    _ dispatchQueue: DispatchQueue)
    -> GenericDispatchStoreWrapper<State>
  {
    let mutex = NSLock()
    let store = GenericDispatchStore(initialState, reducer, dispatchQueue)
    let wrapper = MinimalDispatchStoreWrapper(store, mutex)
    return GenericDispatchStoreWrapper(wrapper)
  }
}
