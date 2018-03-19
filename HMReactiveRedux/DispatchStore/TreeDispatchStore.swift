//
//  TreeDispatchStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 18/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import SwiftFP

/// This store implementation uses TreeState as the default state type. It
/// builds upon the generic store.
public final class TreeDispatchStore<V> {
  public typealias State = TreeState<Value>

  fileprivate let genericStore: GenericDispatchStore<TreeState<Value>>

  init(_ genericStore: GenericDispatchStore<State>) {
    self.genericStore = genericStore
  }
}

extension TreeDispatchStore: ReduxStoreType {
  public func dispatch<S>(_ actions: S) where S: Sequence, S.Iterator.Element == Action {
    genericStore.dispatch(actions)
  }
}

extension TreeDispatchStore: MinimalDispatchStoreType {
  public func lastState() -> TreeState<V> {
    return genericStore.lastState()
  }

  public func unregister<S>(_ ids: S) -> Int where S: Sequence, S.Iterator.Element == String {
    return genericStore.unregister(ids)
  }
}

extension TreeDispatchStore: TreeDispatchStoreType {
  public typealias Value = V

  public func lastValue(_ id: String) -> Try<Value> {
    return genericStore.lastState().stateValue(id)
  }

  public func register(_ id: String,
                       _ path: String,
                       _ callback: @escaping TreeReduxCallback<Value>) {
    let genericCallback: GenericReduxCallback<TreeState<Value>> = {
      try callback($0.stateValue(path))
    }

    genericStore.register(id, genericCallback)
  }
}

public extension TreeDispatchStore {

  /// Create a tree dispatch store instance wrapper.
  ///
  /// - Parameters:
  ///   - initialState: The initial state.
  ///   - reducer: A ReduxReducer instance.
  ///   - dispatchQueue: A DispatchQueue instance.
  /// - Returns: A GenericDispatchStoreWrapper instance.
  public static func createInstance(_ initialState: State,
                                    _ reducer: @escaping ReduxReducer<State>,
                                    _ dispatchQueue: DispatchQueue)
    -> TreeDispatchStoreWrapper<V>
  {
    let mutex = NSLock()
    let genericStore = GenericDispatchStore(initialState, reducer, dispatchQueue)
    let store = TreeDispatchStore(genericStore)
    let wrapper = MinimalDispatchStoreWrapper(store, mutex)
    return TreeDispatchStoreWrapper(wrapper)
  }
}
