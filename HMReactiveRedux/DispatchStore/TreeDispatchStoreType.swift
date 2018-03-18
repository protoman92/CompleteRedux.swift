//
//  TreeDispatchStoreType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 18/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import SwiftFP

/// Callback for TreeState.
public typealias TreeReduxCallback<Value> = (Try<Value>) throws -> Void

/// Represents a tree-based dispatch store.
public protocol TreeDispatchStoreType: MinimalDispatchStoreType where Self.State == TreeState<Value> {
  associatedtype Value

  func lastValue(_ id: String) -> Try<Value>

  /// Register a callback at a path for some id.
  ///
  /// - Parameters:
  ///   - id: The registrant's id.
  ///   - path: The path to be listened to.
  ///   - callback: A TreeReduxCallback instance.
  func register(_ id: String,
                _ path: String,
                _ callback: @escaping TreeReduxCallback<Value>)
}
