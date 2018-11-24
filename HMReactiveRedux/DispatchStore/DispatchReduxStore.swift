//
//  DispatchReduxStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 20/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP

public typealias DispatchCallback<T> = (T) throws -> Void

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
  func register(_ info: Registry, _ callback: @escaping DispatchCallback<CBValue>)
  
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

/// Convenience class to get around Swift's generic constraints. Other stores
/// should extend from this.
open class DispatchReduxStore<State, RegistryInfo, CBValue> {
  public var lastState: Try<State> {
    fatalError("Must override this")
  }
  
  public func dispatch(_ actions: Action) {
    fatalError("Must override this")
  }

  public func register(_ info: RegistryInfo,
                       _ callback: @escaping DispatchCallback<CBValue>) {
    fatalError("Must override this")
  }

  public func unregister<S>(_ ids: S) -> Int where S: Sequence, S.Element == String {
    fatalError("Must override this")
  }
}

extension DispatchReduxStore: DispatchReduxStoreType {}
