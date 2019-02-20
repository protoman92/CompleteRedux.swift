//
//  Redux+EnhancedStore.swift
//  SwiftRedux
//
//  Created by Hai Pham on 12/1/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux.Store {

  /// Enhanced store that can overwrite a base store's action dispatcher.
  struct EnhancedStore<State> {
    private let _store: Redux.Store.DelegateStore<State>
    private let _dispatch: Dispatch
    
    /// Delegate all functionalities to a Redux store instance but customize
    /// the dispatcher.
    init<S>(_ store: S, _ dispatch: @escaping Dispatch) where
      S: ReduxStoreType, S.State == State
    {
      self._store = Redux.Store.DelegateStore(store)
      self._dispatch = dispatch
    }
  }
}

extension Redux.Store.EnhancedStore: ReduxStoreType {
  public var lastState: Redux.Store.LastState<State> {
    return self._store.lastState
  }
  
  public var subscribeState: Redux.Store.Subscribe<State> {
    return self._store.subscribeState
  }
  
  public var dispatch: Redux.Store.Dispatch {
    return self._dispatch
  }
}
