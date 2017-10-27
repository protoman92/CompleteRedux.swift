//
//  HMReduxStoreType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Holmusk. All rights reserved.
//

import RxSwift

/// Classes that implement this protocol should be able to produce state based
/// on reducers.
public protocol HMStateFactoryType {
    associatedtype Action: HMActionType
    associatedtype State: HMStateType
}

public extension HMStateFactoryType {
    
    /// Create a state stream that builds up from an initial state.
    ///
    /// - Parameters:
    ///   - actionTrigger: The action trigger Observable.
    ///   - initialState: The initial state.
    ///   - mainReducer: A Reducer function.
    /// - Returns: An Observable instance.
    public func createState<O>(_ actionTrigger: O,
                               _ initialState: State,
                               _ mainReducer: @escaping HMReducer<Action,State>)
        -> Observable<State> where
        O: ObservableConvertibleType, O.E == Action
    {
        return actionTrigger.asObservable()
            .scan(initialState, accumulator: mainReducer)
    }
}
