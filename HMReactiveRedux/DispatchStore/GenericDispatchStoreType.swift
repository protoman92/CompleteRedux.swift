//
//  GenericDispatchStoreType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 18/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

/// Use this for state callback.
public typealias GenericReduxCallback<State> = (State) throws -> Void

/// Represents a generic dispatch store.
public protocol GenericDispatchStoreType: MinimalDispatchStoreType {

  /// Register a callback for an id.
  ///
  /// - Parameters:
  ///   - id: The registrant's id.
  ///   - callback: A ReduxCallback instance.
  func register(_ id: String, _ callback: @escaping GenericReduxCallback<State>)
}
