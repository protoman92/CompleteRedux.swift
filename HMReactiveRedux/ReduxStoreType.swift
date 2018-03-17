//
//  ReduxStoreType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 17/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

/// This represents a Redux store that can dispatch events.
public protocol ReduxStoreType {

  /// Dispatch an event and notify listeners.
  ///
  /// - Parameter action: A ReduxActionType instance.
  func dispatch(_ action: ReduxActionType)
}
