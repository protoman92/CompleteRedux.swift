//
//  ConcurrentDispatchStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 18/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP

/// Convenience typealias for a concurrent generic dispatch store.
public typealias ConcurrentGenericDispatchStore<State> =
  ConcurrentDispatchStore<State, String, State>

/// Wrapper for dispatch store to provide synchronization.
public final class ConcurrentDispatchStore<State, Registry, CBValue>:
  DispatchReduxStore<State, Registry, CBValue>
{
  public typealias Store = DispatchReduxStore<State, Registry, CBValue>

  override public var lastState: Try<State> {
    self.mutex.lock()
    defer { self.mutex.unlock() }
    return self.store.lastState
  }

  private let mutex: NSLock
  private let store: Store

  public init(_ store: Store) {
    self.store = store
    self.mutex = NSLock()
  }

  override public func dispatch(_ action: Action) {
    self.mutex.lock()
    defer { self.mutex.unlock() }
    self.store.dispatch(action)
  }

  override public func register(_ info: Registry,
                                _ callback: @escaping DispatchCallback<CBValue>) {
    self.mutex.lock()
    defer { self.mutex.unlock() }
    self.store.register(info, callback)
  }

  override public func unregister<S>(_ ids: S) -> Int where S: Sequence, S.Element == String {
    self.mutex.lock()
    defer { self.mutex.unlock() }
    return self.store.unregister(ids)
  }
}

public extension ConcurrentDispatchStore {

  /// Convenience method to create a concurrent dispatch store wrapper.
  ///
  /// - Parameter store: A DispatchReduxStore instance.
  /// - Returns: A ConcurrentDispatchStore instance.
  private static func _createInstance(_ store: DispatchReduxStore<State, Registry, CBValue>)
    -> ConcurrentDispatchStore<State, Registry, CBValue>
  {
    return ConcurrentDispatchStore(store)
  }
}

public extension ConcurrentGenericDispatchStore {
  public static func createInstance(_ store: GenericDispatchStore<State>)
    -> ConcurrentGenericDispatchStore<State>
  {
    return ConcurrentGenericDispatchStore<State>._createInstance(store)
  }
}
