//
//  TreeState.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import SwiftFP
import SwiftUtilities

/// A simple nested state implementation. All TreeState instances are immutable.
public struct TreeState<Value> {
  fileprivate var values: [String : Value]
  fileprivate var substates: [String : TreeState]
  fileprivate var substateSeparator: Character

  fileprivate init() {
    values = [:]
    substates = [:]

    // This separator is used to separate identifiers to access inner state.
    // For example, if the identifier is 'a.b.c' and the separator is '.',
    // this state will first access substate 'a', then 'b' and finally 'c'.
    substateSeparator = "."
  }
}

extension TreeState: CustomStringConvertible {
  public var description: String {
    return "Current state: \(values). Current substate: \(substates)"
  }
}

extension TreeState: StateType {
  public static func empty() -> TreeState {
    return TreeState.builder().build()
  }

  public func stateValue(_ identifier: String) -> Try<Value> {
    let separator = substateSeparator
    let separated = identifier.split(separator: separator).map(String.init)

    if separated.count == 1, let first = separated.first {
      return values[first].asTry("No value at \(identifier)")
    } else if let first = separated.first {
      let subId = separated.dropFirst().joined(separator: String(separator))
      return substate(first).flatMap({$0.stateValue(subId)})
    } else {
      return Try.failure("No value at \(identifier)")
    }
  }

  public func map(_ identifier: String, _ valueFn: UpdateFn) -> TreeState {
    let separator = substateSeparator
    let separated = identifier.split(separator: separator).map(String.init)

    if separated.count == 1, let first = separated.first {
      return cloneBuilder().updateValueFn(first, valueFn).build()
    } else if let first = separated.first {
      let subId = separated.dropFirst().joined(separator: String(separator))
      let substate = self.substate(first).getOrElse(.empty())
      let updatedSubstate = substate.map(subId, valueFn)
      return cloneBuilder().updateSubstate(first, updatedSubstate).build()
    } else {
      return self
    }
  }

  public func clear() -> TreeState {
    return .empty()
  }

  public func isEmpty() -> Bool {
    return values.isEmpty && substates.isEmpty
  }
}

public extension TreeState {

  /// Get a substate at a particular node.
  ///
  /// - Parameter identifier: A String value.
  /// - Returns: A Try TreeState instance.
  public func substate(_ identifier: String) -> Try<TreeState<Value>> {
    let separator = substateSeparator
    let separated = identifier.split(separator: separator).map(String.init)

    if separated.count == 1, let first = separated.first {
      return substates[first].asTry("No substate found at \(identifier)")
    } else if let first = separated.first {
      let subId = separated.dropFirst().joined(separator: String(separator))
      return substate(first).flatMap({$0.substate(subId)})
    } else {
      return Try.failure("No substate found at \(identifier)")
    }
  }

  /// Update a substate at a particular node, and create whatever missing
  /// nodes in the process.
  ///
  /// - Parameters:
  ///   - identifier: A String value.
  ///   - substate: A TreeState instance.
  /// - Returns: A TreeState instance.
  public func updateSubstate(_ identifier: String, _ substate: TreeState?) -> TreeState {
    let separator = substateSeparator
    let separated = identifier.split(separator: separator).map(String.init)

    if separated.count == 1, let first = separated.first {
      return cloneBuilder().updateSubstate(first, substate).build()
    } else if let first = separated.first {
      let subId = separated.dropFirst().joined(separator: String(separator))
      let firstSubstate = self.substate(first).getOrElse(.empty())
      let updatedSubstate = firstSubstate.updateSubstate(subId, substate)
      return updateSubstate(first, updatedSubstate)
    } else {
      return self
    }
  }

  /// Convenience method to remove substate at a node.
  ///
  /// - Parameter identifier: A String value.
  /// - Returns: A TreeState instance.
  public func removeSubstate(_ identifier: String) -> TreeState {
    return updateSubstate(identifier, nil)
  }
}

extension TreeState: BuildableType {
  public static func builder() -> Builder {
    return Builder()
  }

  public final class Builder {
    fileprivate var state: Buildable

    fileprivate init() {
      state = Buildable()
    }

    /// Set the current state.
    ///
    /// - Parameter currentState: A Dictionary instance.
    /// - Returns: The current Builder instance.
    @discardableResult
    public func with(currentState: [String : Value]) -> Self {
      state.values = currentState
      return self
    }

    /// Set substates.
    ///
    /// - Parameter substate: A Dictionary instance.
    /// - Returns: The current Builder instance.
    @discardableResult
    public func with(substate: [String : TreeState]) -> Self {
      state.substates = substate
      return self
    }

    /// Update a value with an update function.
    ///
    /// - Parameters:
    ///   - identifier: A String value.
    ///   - updateFn: An update function.
    /// - Returns: The current Builder instance.
    @discardableResult
    public func updateValueFn(_ identifier: String, _ updateFn: UpdateFn) -> Self {
      let newValue = updateFn(state.stateValue(identifier))

      if let value = newValue.value {
        state.values.updateValue(value, forKey: identifier)
      } else {
        state.values.removeValue(forKey: identifier)
      }

      return self
    }

    /// Update the current state with a value.
    ///
    /// - Parameters:
    ///   - identifier: A String value.
    ///   - value: A Try Value instance.
    /// - Returns: The current Builder instance.
    @discardableResult
    public func updateValue(_ identifier: String, _ value: Try<Value>) -> Self {
      let valueFn: UpdateFn = {_ in value}
      return updateValueFn(identifier, valueFn)
    }

    /// Update the current state with a value.
    ///
    /// - Parameters:
    ///   - identifier: A String value.
    ///   - value: A Value instance.
    /// - Returns: The current Builder instance.
    @discardableResult
    public func updateValue(_ identifier: String, _ value: Value?) -> Self {
      return updateValue(identifier, value.asTry())
    }

    /// Update substate.
    ///
    /// - Parameters:
    ///   - identifier: A String value.
    ///   - substate: A TreeState instance.
    /// - Returns: The current Builder instance.
    @discardableResult
    public func updateSubstate(_ identifier: String, _ substate: TreeState?) -> Self {
      if let substate = substate {
        state.substates.updateValue(substate, forKey: identifier)
      } else {
        state.substates.removeValue(forKey: identifier)
      }

      return self
    }

    /// Set the substate separator.
    ///
    /// - Parameter substateSeparator: A Character instance.
    /// - Returns: The current Builder instance.
    @discardableResult
    public func with(substateSeparator: Character) -> Self {
      state.substateSeparator = substateSeparator
      return self
    }
  }
}

extension TreeState.Builder: BuilderType {
  public typealias Buildable = TreeState

  @discardableResult
  public func with(buildable: Buildable?) -> Self {
    if let buildable = buildable {
      return self
        .with(currentState: buildable.values)
        .with(substate: buildable.substates)
        .with(substateSeparator: buildable.substateSeparator)
    } else {
      return self
    }
  }

  public func build() -> Buildable {
    return state
  }
}
