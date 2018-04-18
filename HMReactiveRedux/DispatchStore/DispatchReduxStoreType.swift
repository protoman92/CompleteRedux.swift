//
//  ReduxDispatchStoreType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 20/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public typealias ReduxCallback<T> = (T) throws -> Void

/// Represents a dispatch-based Redux store.
public protocol DispatchReduxStoreType: ReduxStoreType {

  /// Use this to type-check registery information. For e.g., generic dispatch
  /// store (with custom state) should only define this as String. This must
  /// always contain the registrant's id.
  associatedtype Registry

  /// Use this to type-check callback values.
  associatedtype CBValue

  /// Register a callback based on registry information.
  ///
  /// - Parameters:
  ///   - info: A RegistryInfo instance.
  ///   - callback: A Callback function.
  func register(_ info: Registry, _ callback: @escaping ReduxCallback<CBValue>)

  /// Unregister all callbacks for some ids.
  ///
  /// - Parameter ids: The registrant's ids.
  /// - Returns: An Int value indicating the number of removed callbacks.
  func unregister<S>(_ ids: S) -> Int where S: Sequence, S.Element == String
}

public extension DispatchReduxStoreType {

  /// Convenience method to unregister callbacks for some ids.
  ///
  /// - Parameter ids: Varargs of ids.
  /// - Returns: An Int value indicating the number of removed callbacks.
  public func unregister(_ ids: String...) -> Int {
    return unregister(ids)
  }
}
