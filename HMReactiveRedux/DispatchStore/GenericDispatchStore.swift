//
//  DispatchStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 17/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP

final class StrongReference<T> {
  public let value: T

  public init(_ value: T) {
    self.value = value
  }
}

/// This is a simple dispatch-based Redux store with no rx. It can be used to
/// build more specialized store implementations. Keep in mind that this store
/// is not thread-safe, so we can wrap it with ConcurrentDispatchStore for
/// locking.
///
/// The state should be a value data structure to avoid external modifications.
public final class GenericDispatchStore<State>: DispatchReduxStore<State, String, State> {
  override public var lastState: Try<State> {
    return Try.success(state)
  }
  
  private let dispatchQueue: DispatchQueue
  private let reducer: ReduxReducer<State>
  private var callbacks: [(String, [ReduxCallback<CBValue>])]
  private var state: State

  public init(_ initialState: State,
              _ reducer: @escaping ReduxReducer<State>,
              _ dispatchQueue: DispatchQueue) {
    self.dispatchQueue = dispatchQueue
    self.reducer = reducer
    self.callbacks = []
    self.state = initialState
  }

  override public func dispatch(_ action: Action) {
    let newState = self.reducer(self.state, action)
    let newStateRef = StrongReference(newState)
    let callbacks = self.callbacks
    self.state = newState

    self.dispatchQueue.async {
      callbacks.forEach({$1.forEach({try? $0(newStateRef.value)})})
    }
  }

  override public func register(_ id: String, _ callback: @escaping ReduxCallback<CBValue>) {
    var didAdd = false

    for (ix, (key, value)) in self.callbacks.enumerated() {
      if key == id {
        var newValue = value
        newValue.append(callback)
        self.callbacks[ix] = (key, newValue)
        didAdd = true
        break
      }
    }

    if !didAdd {
      var newValue = [ReduxCallback<CBValue>]()
      newValue.append(callback)
      self.callbacks.append((id, newValue))
    }
    
    let lastState = StrongReference(state)

    /// Relay the last event.
    self.dispatchQueue.async {try? callback(lastState.value)}
  }

  override public func unregister<S>(_ ids: S) -> Int where S: Sequence, S.Element == String {
    var unregistered = 0
    var newCallbacks = [(String, [ReduxCallback<CBValue>])]()

    for (key, value) in self.callbacks {
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

extension GenericDispatchStore: GenericDispatchStoreType {}
