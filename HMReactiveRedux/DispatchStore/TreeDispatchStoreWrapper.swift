//
//  TreeDispatchStoreWrapper.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 18/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import SwiftFP

public final class TreeDispatchStoreWrapper<V> {
  public typealias Store = TreeDispatchStore<Value>

  fileprivate let wrapper: MinimalDispatchStoreWrapper<Store>

  init(_ wrapper: MinimalDispatchStoreWrapper<Store>) {
    self.wrapper = wrapper
  }
}

extension TreeDispatchStoreWrapper: ReduxStoreType {
  public func dispatch<S>(_ actions: S) where S: Sequence, S.Iterator.Element == Action {
    return wrapper.dispatch(actions)
  }
}

extension TreeDispatchStoreWrapper: MinimalDispatchStoreType {
  public typealias State = Store.State

  public func lastState() -> TreeState<Value> {
    return wrapper.lastState()
  }

  public func unregister<S>(_ ids: S) -> Int where S : Sequence, S.Element == String {
    return wrapper.unregister(ids)
  }
}

extension TreeDispatchStoreWrapper: TreeDispatchStoreType {
  public typealias Value = V

  public func lastValue(_ id: String) -> Try<V> {
    wrapper.mutex.lock()
    defer { wrapper.mutex.unlock() }
    return wrapper.store.lastValue(id)
  }

  public func register(_ id: String,
                       _ path: String,
                       _ callback: @escaping (Try<V>) throws -> Void) {
    wrapper.mutex.lock()
    defer { wrapper.mutex.unlock() }
    wrapper.store.register(id, path, callback)
  }
}
