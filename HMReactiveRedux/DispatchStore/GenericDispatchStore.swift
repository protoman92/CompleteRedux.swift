//
//  DispatchStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 17/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import SwiftFP

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
  fileprivate var callbacks: [String : [GenericReduxCallback<State>]]
  fileprivate var state: State

  init(_ initialState: State,
       _ reducer: @escaping ReduxReducer<State>,
       _ dispatchQueue: DispatchQueue) {
    self.dispatchQueue = dispatchQueue
    self.reducer = reducer
    callbacks = [:]
    state = initialState
  }
}

extension GenericDispatchStore: ReduxStoreType {
  public func dispatch(_ action: ReduxActionType) {
    let newState = StrongReference(reducer(self.state, action))
    let callbacks = self.callbacks

    dispatchQueue.async {
      callbacks.forEach({$0.value.forEach({try? $0(newState.value)})})
    }

    self.state = newState.value
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

    for id in ids {
      if callbacks.removeValue(forKey: id) != nil {
        unregistered += 1
      }
    }

    return unregistered
  }
}

extension GenericDispatchStore: GenericDispatchStoreType {
  public func register(_ id: String, _ callback: @escaping GenericReduxCallback<State>) {
    var callbacksForRegistrant = callbacks[id] ?? []
    callbacksForRegistrant.append(callback)
    callbacks[id] = callbacksForRegistrant
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
