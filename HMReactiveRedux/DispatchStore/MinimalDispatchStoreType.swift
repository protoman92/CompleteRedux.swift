//
//  MinimalDispatchStoreType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 18/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

/// Represents a store with minimal exposed methods.
public protocol MinimalDispatchStoreType: ReduxStoreType {
  associatedtype State

  func lastState() -> State

  /// Unregister all callbacks for some ids.
  ///
  /// - Parameter ids: The registrant's ids.
  /// - Returns: An Int value indicating the number of removed callbacks.
  func unregister<S>(_ ids: S) -> Int where S: Sequence, S.Iterator.Element == String
}

public extension MinimalDispatchStoreType {
  
  /// Convenience method to unregister all callbacks for some ids.
  ///
  /// - Parameter ids: Varargs of ids.
  /// - Returns: An Int value indicating the number of removed callbacks.
  public func unregister(_ ids: String...) -> Int {
    return unregister(ids)
  }
}
