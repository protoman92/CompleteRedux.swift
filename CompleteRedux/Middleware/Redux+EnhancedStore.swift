//
//  Redux+EnhancedStore.swift
//  CompleteRedux
//
//  Created by Hai Pham on 12/1/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Enhanced store that can overwrite a base store's action dispatcher.
struct EnhancedStore<State> {
  private let store: DelegateStore<State>
  private let _dispatch: AwaitableReduxDispatcher
  
  /// Delegate all functionalities to a Redux store instance but customize
  /// the dispatcher.
  init<S>(_ store: S, _ dispatch: @escaping AwaitableReduxDispatcher) where
    S: ReduxStoreType, S.State == State
  {
    self.store = DelegateStore(store)
    self._dispatch = dispatch
  }
}

extension EnhancedStore: ReduxStoreType {
  public var dispatch: AwaitableReduxDispatcher {
    return self._dispatch
  }
  
  public var lastState: ReduxStateGetter<State> {
    return self.store.lastState
  }
  
  public var subscribeState: ReduxSubscriber<State> {
    return self.store.subscribeState
  }
  
  public var unsubscribe: ReduxUnsubscriber {
    return self.store.unsubscribe
  }
}
