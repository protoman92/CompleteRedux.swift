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
    fileprivate var currentState: [String : Any]
    fileprivate var substate: [String : HMState]
    
    fileprivate init() {
        currentState = [:]
        substate = [:]
    }
    
    public func stateValue(_ identifier: String) -> Any? {
        return currentState[identifier]
    }
    
    public func substate(_ identifier: String) -> HMState? {
        return self.substate[identifier]
    }
}

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
        public func with(currentState: [String : Any]) -> Self {
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
        
        /// Update the current state.
        ///
        /// - Parameters:
        ///   - identifier: A String value.
        ///   - value: Any object.
        /// - Returns: The current Builder instance.
        @discardableResult
        public func updateState(_ identifier: String, _ value: Any) -> Self {
            state.currentState.updateValue(value, forKey: identifier)
            return self
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
        } else {
            return self
        }
    }
    
    public func build() -> Buildable {
        return state
    }
}
