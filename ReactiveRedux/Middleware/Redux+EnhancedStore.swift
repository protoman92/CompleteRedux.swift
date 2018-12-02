//
//  Redux+EnhancedStore.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/1/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux {

  /// Enhanced store that can overwrite dispatch from a base store.
  struct EnhancedStore<State> {
    private let _dispatch: Redux.Dispatch
    private let _lastState: () -> State
    private let _subscribe: Redux.Subscribe<State>
    
    init<S>(store: S, dispatch: @escaping Dispatch) where
      S: ReduxStoreType, S.State == State
    {
      self._dispatch = dispatch
      self._lastState = store.lastState
      self._subscribe = store.subscribeState
    }
  }
}

extension Redux.EnhancedStore: ReduxStoreType {
  public var lastState: Redux.LastState<State> {
    return self._lastState
  }
  
  public var subscribeState: Redux.Subscribe<State> {
    return self._subscribe
  }
  
  public var dispatch: Redux.Dispatch {
    return self._dispatch
  }
}
