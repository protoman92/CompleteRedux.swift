//
//  TreeDispatchStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 18/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP

/// This store implementation uses TreeState as the default state type. It
/// builds upon the generic store. The RegistryInfo contains both the registrant
/// id and the path it's interested in.
///
/// This store is not thread-safe, so we should wrap it with ConcurrentDispatchStore.
public final class TreeDispatchStore<V>: DispatchReduxStore<TreeState<V>, (String, String), Try<V>> {
  fileprivate let genericStore: GenericDispatchStore<TreeDispatchStore.State>

  public init(_ genericStore: GenericDispatchStore<TreeDispatchStore.State>) {
    self.genericStore = genericStore
  }

  override public func dispatch<S>(_ actions: S) where S: Sequence, S.Element == Action {
    genericStore.dispatch(actions)
  }

  override public func lastState() -> State {
    return genericStore.lastState()
  }

  override public func unregister<S>(_ ids: S) -> Int where S: Sequence, S.Element == String {
    return genericStore.unregister(ids)
  }

  override public func register(_ info: Registry, _ callback: @escaping ReduxCallback<CBValue>) {
    let path = info.1

    let genericCallback: ReduxCallback<TreeState<V>> = {
      try callback($0.stateValue(path))
    }

    genericStore.register(info.0, genericCallback)
  }
}

extension TreeDispatchStore: TreeDispatchStoreType {
  public typealias Value = V
}
