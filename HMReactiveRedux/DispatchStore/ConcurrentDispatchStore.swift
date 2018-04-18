//
//  ConcurrentDispatchStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 18/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP

/// Wrapper for dispatch store to provide synchronization.
public final class ConcurrentDispatchStore<State, Registry, CBValue>:
  DispatchReduxStore<State, Registry, CBValue>
{
  public typealias Store = DispatchReduxStore<State, Registry, CBValue>

  override public var lastState: Try<State> {
    mutex.lock()
    defer { mutex.unlock() }
    return store.lastState
  }

  fileprivate let mutex: NSLock
  fileprivate let store: Store

  public init(_ store: Store) {
    self.store = store
    mutex = NSLock()
  }

  override public func dispatch<S>(_ actions: S) where S: Sequence, S.Element == Action {
    mutex.lock()
    defer { mutex.unlock() }
    store.dispatch(actions)
  }

  override public func register(_ info: Registry, _ callback: @escaping ReduxCallback<CBValue>) {
    mutex.lock()
    defer { mutex.unlock() }
    store.register(info, callback)
  }

  override public func unregister<S>(_ ids: S) -> Int where S: Sequence, S.Element == String {
    mutex.lock()
    defer { mutex.unlock() }
    return store.unregister(ids)
  }
}

public extension ConcurrentDispatchStore {

  /// Convenience method to create a concurrent dispatch store wrapper. If in
  /// debug mode, add some wrappers to the generic store to provide debugging
  /// capabilities.
  ///
  /// - Parameter store: A DispatchReduxStore instance.
  /// - Returns: A ConcurrentDispatchStore instance.
  fileprivate static func _createInstance(_ store: DispatchReduxStore<State, Registry, CBValue>)
    -> ConcurrentDispatchStore<State, Registry, CBValue>
  {
    #if DEBUG
    let lastActionStore = LastActionDispatchStore(store)
    return ConcurrentDispatchStore<State, Registry, CBValue>(lastActionStore)
    #else
    return ConcurrentDispatchStore(store)
    #endif
  }
}

public extension ConcurrentGenericDispatchStore {
  public static func createInstance(_ store: GenericDispatchStore<State>)
    -> ConcurrentGenericDispatchStore<State>
  {
    return ConcurrentGenericDispatchStore<State>._createInstance(store)
  }
}

public extension ConcurrentTreeDispatchStore {
  public static func createInstance<V>(_ store: TreeDispatchStore<V>)
    -> ConcurrentTreeDispatchStore<V>
  {
    return ConcurrentTreeDispatchStore<V>._createInstance(store)
  }
}

public extension ConcurrentDispatchStore where State: TreeStateType {
  public func lastValue(_ path: String) -> Try<State.Value> {
    mutex.lock()
    defer { mutex.unlock() }
    return store.lastState.flatMap({$0.stateValue(path)})
  }
}
