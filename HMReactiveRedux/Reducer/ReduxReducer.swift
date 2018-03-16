//
//  ReduxReducer.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

/// Represent a reducer that takes an action and a state to produce another
/// state.
public typealias ReduxReducer<State> = (State, ReduxActionType) -> State
