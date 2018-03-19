//
//  GenericDispatchStoreWrapper.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 18/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

/// Wrapper for generic dispatch store.
public final class GenericDispatchStoreWrapper<S> {
  public typealias Store = GenericDispatchStore<S>

  fileprivate let wrapper: MinimalDispatchStoreWrapper<Store>

  init(_ wrapper: MinimalDispatchStoreWrapper<Store>) {
    self.wrapper = wrapper
  }
}

extension GenericDispatchStoreWrapper: ReduxStoreType {
  public func dispatch<S>(_ actions: S) where S: Sequence, S.Iterator.Element == Action {
    wrapper.dispatch(actions)
  }
}

extension GenericDispatchStoreWrapper: MinimalDispatchStoreType {
  public typealias State = S

  public func lastState() -> State {
    return wrapper.lastState()
  }

  public func unregister<S>(_ ids: S) -> Int where S : Sequence, S.Element == String {
    return wrapper.unregister(ids)
  }
}

extension GenericDispatchStoreWrapper: GenericDispatchStoreType {
  public func register(_ id: String, _ callback: @escaping (S) throws -> Void) {
    wrapper.mutex.lock()
    defer { wrapper.mutex.unlock() }
    wrapper.store.register(id, callback)
  }
}
