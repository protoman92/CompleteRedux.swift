//
//  HMStateStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 28/10/17.
//  Copyright © 2017 Holmusk. All rights reserved.
//

import RxSwift

/// A Redux-compliant store that specifically handles HMState.
public typealias HMStateStore = HMReduxStore<HMState>

public extension HMReduxStore where State == HMState {
    
    /// Subscribe to this stream to receive notifications for a particular
    /// substate. Beware that this stream may be empty if the substate in question
    /// does not exist.
    ///
    /// - Parameter identifier: A String value.
    /// - Returns: An Observable instance.
    public func substateStream(_ identifier: String) -> Observable<State> {
        return stateStream().mapNonNilOrEmpty({$0.substate(identifier)})
    }
    
    /// Subscribe to this stream to receive notifications for a particular
    /// state value. Beware that this stream may be empty if the state value
    /// does not exist.
    ///
    /// - Parameter identifier: A String value.
    /// - Returns: An Observable instance.
    public func stateValueStream(_ identifier: String) -> Observable<Any> {
        return stateStream().mapNonNilOrEmpty({$0.stateValue(identifier)})
    }
    
    /// Subscribe to this stream to receive notifications for a state value of
    /// a specified type.
    ///
    /// - Parameters:
    ///   - cls: The T class type.
    ///   - identifier: A String value.
    /// - Returns: An Observable instance.
    public func stateValueStream<T>(_ cls: T.Type, _ identifier: String) -> Observable<T> {
        return stateValueStream(identifier).ofType(cls)
    }
}
