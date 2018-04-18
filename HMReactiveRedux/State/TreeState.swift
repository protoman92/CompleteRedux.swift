//
//  TreeState.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import SwiftFP

/// A simple nested state implementation. All TreeState instances are immutable.
public struct TreeState<Value> {
  fileprivate var values: [String : Value]
  fileprivate var substates: [String : TreeState]
  fileprivate var substateSeparator: Character

  fileprivate init() {
    values = [:]
    substates = [:]

    // This separator is used to separate paths to access inner state.
    // For example, if the path is 'a.b.c' and the separator is '.',
    // this state will first access substate 'a', then 'b' and finally 'c'.
    substateSeparator = "."
  }
}

extension TreeState: CustomStringConvertible {
  public var description: String {
    return "Current state: \(values). Current substate: \(substates)"
  }
}

extension TreeState: TreeStateType {

  /// This typealias is for backward-compatibility.
  public typealias UpdateFn<Value> = (Try<Value>) -> Try<Value>

  public static func empty() -> TreeState {
    return TreeState.builder().build()
  }

  fileprivate func cloneBuilder() -> Builder {
    return Builder().with(buildable: self)
  }

  public func stateValue(_ path: String) -> Try<Value> {
    let separator = substateSeparator
    let separated = path.split(separator: separator).map(String.init)

    if separated.count == 1, let first = separated.first {
      return values[first].asTry("No value at \(path)")
    } else if let first = separated.first {
      let subId = separated.dropFirst().joined(separator: String(separator))
      return substate(first).flatMap({$0.stateValue(subId)})
    } else {
      return Try.failure("No value at \(path)")
    }
  }

  public func map(_ path: String, _ valueFn: UpdateFn<Value>) -> TreeState {
    let separator = substateSeparator
    let separated = path.split(separator: separator).map(String.init)

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
  /// - Parameter path: A String value.
  /// - Returns: A Try TreeState instance.
  public func substate(_ path: String) -> Try<TreeState<Value>> {
    let separator = substateSeparator
    let separated = path.split(separator: separator).map(String.init)

    if separated.count == 1, let first = separated.first {
      return substates[first].asTry("No substate found at \(path)")
    } else if let first = separated.first {
      let subId = separated.dropFirst().joined(separator: String(separator))
      return substate(first).flatMap({$0.substate(subId)})
    } else {
      return Try.failure("No substate found at \(path)")
    }
  }

  /// Update a substate at a particular node, and create whatever missing
  /// nodes in the process.
  ///
  /// - Parameters:
  ///   - path: A String value.
  ///   - substate: A TreeState instance.
  /// - Returns: A TreeState instance.
  public func updateSubstate(_ path: String, _ substate: TreeState?) -> TreeState {
    let separator = substateSeparator
    let separated = path.split(separator: separator).map(String.init)

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
  /// - Parameter path: A String value.
  /// - Returns: A TreeState instance.
  public func removeSubstate(_ path: String) -> TreeState {
    return updateSubstate(path, nil)
  }
}

extension TreeState {
  public static func builder() -> Builder {
    return Builder()
  }

  public final class Builder {
    fileprivate var state: TreeState<Value>

    fileprivate init() {
      state = TreeState()
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
    ///   - path: A String value.
    ///   - updateFn: An update function.
    /// - Returns: The current Builder instance.
    @discardableResult
    public func updateValueFn(_ path: String, _ updateFn: UpdateFn<Value>) -> Self {
      let newValue = updateFn(state.stateValue(path))

      if let value = newValue.value {
        state.values.updateValue(value, forKey: path)
      } else {
        state.values.removeValue(forKey: path)
      }

      return self
    }

    /// Update the current state with a value.
    ///
    /// - Parameters:
    ///   - path: A String value.
    ///   - value: A Try Value instance.
    /// - Returns: The current Builder instance.
    @discardableResult
    public func updateValue(_ path: String, _ value: Try<Value>) -> Self {
      let valueFn: UpdateFn = {_ in value}
      return updateValueFn(path, valueFn)
    }

    /// Update the current state with a value.
    ///
    /// - Parameters:
    ///   - path: A String value.
    ///   - value: A Value instance.
    /// - Returns: The current Builder instance.
    @discardableResult
    public func updateValue(_ path: String, _ value: Value?) -> Self {
      return updateValue(path, value.asTry())
    }

    /// Update substate.
    ///
    /// - Parameters:
    ///   - path: A String value.
    ///   - substate: A TreeState instance.
    /// - Returns: The current Builder instance.
    @discardableResult
    public func updateSubstate(_ path: String, _ substate: TreeState?) -> Self {
      if let substate = substate {
        state.substates.updateValue(substate, forKey: path)
      } else {
        state.substates.removeValue(forKey: path)
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

    @discardableResult
    public func with(buildable: TreeState<Value>?) -> Self {
      if let buildable = buildable {
        return self
          .with(currentState: buildable.values)
          .with(substate: buildable.substates)
          .with(substateSeparator: buildable.substateSeparator)
      } else {
        return self
      }
    }

    public func build() -> TreeState<Value> {
      return state
    }
  }
}
