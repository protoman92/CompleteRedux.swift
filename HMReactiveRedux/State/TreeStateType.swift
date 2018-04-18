//
//  TreeStateType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import SwiftFP

/// Classes that implement this protocol should act as tree-based state.
public protocol TreeStateType {
  associatedtype Value
  typealias UpdateFunc = (Try<Value>) -> Try<Value>

  /// Get an empty state.
  ///
  /// - Returns: A Self instance.
  static func empty() -> Self

  /// Get value at a particular node.
  ///
  /// - Parameter path: A String value.
  /// - Returns: A Try Value instance.
  func stateValue(_ path: String) -> Try<Value>

  /// Update the current state using a value function. If the require nodes
  /// do not exist, create it to store this value.
  ///
  /// - Parameters:
  ///   - path: A String value.
  ///   - valueFn: Value update function.
  /// - Returns: A Self instance.
  func map(_ path: String, _ valueFn: UpdateFunc) -> Self

  /// Get a new blank state.
  ///
  /// - Returns: A Self instance.
  func clear() -> Self

  /// Check if the current State is empty.
  ///
  /// - Returns: A Bool value.
  func isEmpty() -> Bool
}

public extension TreeStateType {

  /// Convenience function to update a value at a node.
  ///
  /// - Parameters:
  ///   - path: A String value.
  ///   - value: A Try Value instance.
  /// - Returns: A Self instance.
  public func updateValue(_ path: String, _ value: Try<Value>) -> Self {
    let valueFn: UpdateFunc = {_ in value}
    return map(path, valueFn)
  }

  /// Convenience function to update a value at a node.
  ///
  /// - Parameters:
  ///   - path: A String value.
  ///   - value: A Value instance.
  /// - Returns: A Self instance.
  public func updateValue(_ path: String, _ value: Value?) -> Self {
    return updateValue(path, value.asTry())
  }

  /// Convenience method to remove value in the current state/a substate.
  ///
  /// - Parameter path: A String value.
  /// - Returns: A Self instance.
  public func removeValue(_ path: String) -> Self {
    return updateValue(path, Try.failure("Value at \(path) will be removed"))
  }

  /// Convenience method to update values from a dictionary.
  ///
  /// - Parameter dict: A Dictionary instance.
  /// - Returns: A Self instance.
  public func updateValues(_ dict: [String : Value]) -> Self {
    var state = Self.empty()

    for (key, value) in dict {
      state = state.updateValue(key, value)
    }

    return state
  }

  /// Convenience method to remove all values with specified paths.
  ///
  /// - Parameter keys: A Sequence of keys.
  /// - Returns: A Self instance.
  public func removeValues<S>(_ keys: S) -> Self where S: Sequence, S.Element == String {
    var state = Self.empty()

    for key in keys {
      state = state.removeValue(key)
    }

    return state
  }
}
