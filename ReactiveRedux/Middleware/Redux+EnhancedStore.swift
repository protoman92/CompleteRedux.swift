//
//  Redux+EnhancedStore.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/1/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux.Store {

  /// Enhanced store that can overwrite dispatch from a base store.
  struct EnhancedStore<State> {
    private let _dispatch: Dispatch
    private let _lastState: () -> State
    private let _subscribe: Subscribe<State>
    
    init<S>(_ store: S, _ dispatch: @escaping Dispatch) where
      S: ReduxStoreType, S.State == State
    {
      self._dispatch = dispatch
      self._lastState = store.lastState
      self._subscribe = store.subscribeState
    }
  }
}

extension Redux.Store.EnhancedStore: ReduxStoreType {
  public var lastState: Redux.Store.LastState<State> {
    return self._lastState
  }
  
  public var subscribeState: Redux.Store.Subscribe<State> {
    return self._subscribe
  }
  
  public var dispatch: Redux.Store.Dispatch {
    return self._dispatch
  }
}
