//
//  RxReduxStore.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxSwift

/// Classes that implement this protocol should act as a Redux-compliant store.
public protocol RxReduxStoreType: ReduxStoreType {
  
  /// Trigger an action.
  var actionTrigger: AnyObserver<ReduxActionType> { get }
  
  /// Subscribe to this stream to receive state notifications.
  var stateStream: Observable<State> { get }
}
