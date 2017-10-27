//
//  HMState.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Holmusk. All rights reserved.
//

import SwiftUtilities

/// A simple nested state implementation.
public struct HMState {
    public typealias UpdateFn<T> = (T) -> T
    
    public static func empty() -> HMState {
        return HMState.builder().build()
    }
    
    fileprivate var currentState: [String : Any?]
    fileprivate var substate: [String : HMState]
    fileprivate var substateSeparator: Character
    
    fileprivate init() {
        currentState = [:]
        substate = [:]
        
        // This separator is used to separate identifiers to access inner state.
        // For example, if the identifier is 'a.b.c' and the separator is '.',
        // this state will first access substate 'a', then 'b' and finally 'c'.
        substateSeparator = "."
    }
}

public extension HMState {
    
    /// Get the current state value at a particular node.
    ///
    /// - Parameter identifier: A String value.
    /// - Returns: Any object.
    public func stateValue(_ identifier: String) -> Any? {
        let separator = substateSeparator
        let separated = identifier.split(separator: separator).map(String.init)
        
        if separated.count == 1, let first = separated.first {
            return currentState[first] ?? nil
        } else if let first = separated.first {
            let subId = separated.dropFirst().joined(separator: String(separator))
            return substate(first)?.stateValue(subId)
        } else {
            return nil
        }
    }
    
    /// Update the current state using a value function. If the require nodes
    /// do not exist, create it to store this value.
    ///
    /// - Parameters:
    ///   - identifier: A String value.
    ///   - valueFn: Value update function.
    /// - Returns: A HMState instance.
    public func mapValue<T>(_ identifier: String, _ valueFn: UpdateFn<T?>) -> HMState {
        let separator = substateSeparator
        let separated = identifier.split(separator: separator).map(String.init)
        
        if separated.count == 1, let first = separated.first {
            return cloneBuilder().updateStateFn(first, valueFn).build()
        } else if let first = separated.first {
            let subId = separated.dropFirst().joined(separator: String(separator))
            let substate = self.substate(first) ?? .empty()
            let updatedSubstate = substate.mapValue(subId, valueFn)
            return cloneBuilder().updateSubstate(first, updatedSubstate).build()
        } else {
            return self
        }
    }
    
    /// Update with value function, with a convenience class type.
    ///
    /// - Parameters:
    ///   - cls: T class type.
    ///   - identifier: A String value.
    ///   - valueFn: Value update function.
    /// - Returns: A HMState instance.
    public func mapValue<T>(_ cls: T.Type,
                                 _ identifier: String,
                                 _ valueFn: UpdateFn<T?>) -> HMState {
        return mapValue(identifier, valueFn)
    }
    
    /// Only update a value if it is of type T.
    ///
    /// - Parameters:
    ///   - identifier: A String value.
    ///   - valueFn: Value update function.
    /// - Returns: A HMState instance.
    public func mapValueIfAvailable<T>(_ identifier: String,
                                            _ valueFn: UpdateFn<T>) -> HMState {
        if let currentValue = stateValue(identifier) as? T {
            let newValue = valueFn(currentValue)
            return updateValue(identifier, newValue)
        } else {
            return self
        }
    }
    
    /// Only update a value if it is of type T.
    ///
    /// - Parameters:
    ///   - cls: T class type.
    ///   - identifier: A String value.
    ///   - valueFn: Value update function.
    /// - Returns: A HMState instance.
    public func mapValueInAvailable<T>(_ cls: T.Type,
                                            _ identifier: String,
                                            _ valueFn: UpdateFn<T>) -> HMState {
        return mapValueIfAvailable(identifier, valueFn)
    }
    
    /// Convenience function to update a value at a node.
    ///
    /// - Parameters:
    ///   - identifier: A String value.
    ///   - value: Any object.
    /// - Returns: A HMState instance.
    public func updateValue(_ identifier: String, _ value: Any?) -> HMState {
        let valueFn: UpdateFn<Any?> = {_ in value}
        return mapValue(identifier, valueFn)
    }
}

public extension HMState {
    
    /// Get a substate at a particular node.
    ///
    /// - Parameter identifier: A String value.
    /// - Returns: A HMState instance.
    public func substate(_ identifier: String) -> HMState? {
        let separator = substateSeparator
        let separated = identifier.split(separator: separator).map(String.init)
        
        if separated.count == 1, let first = separated.first {
            return substate[first]
        } else if let first = separated.first {
            let subId = separated.dropFirst().joined(separator: String(separator))
            return substate(first)?.substate(subId)
        } else {
            return nil
        }
    }
    
    /// Update a substate at a particular node, and create whatever missing
    /// nodes in the process.
    ///
    /// - Parameters:
    ///   - identifier: A String value.
    ///   - substate: A HMState instance.
    /// - Returns: A HMState instance.
    public func updateSubstate(_ identifier: String, _ substate: HMState) -> HMState {
        let separator = substateSeparator
        let separated = identifier.split(separator: separator).map(String.init)
        
        if separated.count == 1, let first = separated.first {
            return cloneBuilder().updateSubstate(first, substate).build()
        } else if let first = separated.first {
            let subId = separated.dropFirst().joined(separator: String(separator))
            let firstSubstate = self.substate(first) ?? .empty()
            let updatedSubstate = firstSubstate.updateSubstate(subId, substate)
            return updateSubstate(first, updatedSubstate)
        } else {
            return self
        }
    }
}

extension HMState: CustomStringConvertible {
    public var description: String {
        return "Current state: \(currentState). Current substate: \(substate)"
    }
}

extension HMState: HMStateType {}

extension HMState: BuildableType {
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
        public func with(currentState: [String : Any?]) -> Self {
            state.currentState = currentState
            return self
        }
        
        /// Set substates.
        ///
        /// - Parameter substate: A Dictionary instance.
        /// - Returns: The current Builder instance.
        @discardableResult
        public func with(substate: [String : HMState]) -> Self {
            state.substate = substate
            return self
        }
        
        /// Update the current state with an update function.
        ///
        /// - Parameters:
        ///   - identifier: A String value.
        ///   - updateFn: An update function.
        /// - Returns: The current Builder instance.
        @discardableResult
        public func updateStateFn<T>(_ identifier: String, _ updateFn: UpdateFn<T?>) -> Self {
            let value = state.stateValue(identifier) as? T
            let newValue = updateFn(value)
            state.currentState.updateValue(newValue, forKey: identifier)
            return self
        }
        
        /// Update the current state with a value.
        ///
        /// - Parameters:
        ///   - identifier: A String value.
        ///   - value: Any object.
        /// - Returns: The current Builder instance.
        @discardableResult
        public func updateState(_ identifier: String, _ value: Any?) -> Self {
            let valueFn: UpdateFn<Any?> = {_ in value}
            return updateStateFn(identifier, valueFn)
        }
        
        /// Update substate.
        ///
        /// - Parameters:
        ///   - identifier: A String value.
        ///   - substate: A HMState instance.
        /// - Returns: The current Builder instance.
        @discardableResult
        public func updateSubstate(_ identifier: String, _ substate: HMState) -> Self {
            state.substate.updateValue(substate, forKey: identifier)
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

extension HMState.Builder: BuilderType {
    public typealias Buildable = HMState
    
    @discardableResult
    public func with(buildable: Buildable?) -> Self {
        if let buildable = buildable {
            return self
                .with(currentState: buildable.currentState)
                .with(substate: buildable.substate)
                .with(substateSeparator: buildable.substateSeparator)
        } else {
            return self
        }
    }
    
    public func build() -> Buildable {
        return state
    }
}
