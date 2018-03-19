//
//  MinimalDispatchStoreWrapper.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 18/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

/// Wrapper to provide locking capabilities.
final class MinimalDispatchStoreWrapper<Store: MinimalDispatchStoreType> {
  let mutex: NSLock
  let store: Store

  public init(_ store: Store, _ mutex: NSLock) {
    self.store = store
    self.mutex = mutex
  }
}

extension MinimalDispatchStoreWrapper: ReduxStoreType {
  public func dispatch<S>(_ actions: S) where S: Sequence, S.Iterator.Element == Action {
    mutex.lock()
    defer { mutex.unlock() }
    store.dispatch(actions)
  }
}

extension MinimalDispatchStoreWrapper: MinimalDispatchStoreType {
  typealias State = Store.State

  func lastState() -> Store.State {
    mutex.lock()
    defer { mutex.unlock() }
    return store.lastState()
  }

  func unregister<S>(_ ids: S) -> Int where S : Sequence, S.Element == String {
    mutex.lock()
    defer { mutex.unlock() }
    return store.unregister(ids)
  }
}
