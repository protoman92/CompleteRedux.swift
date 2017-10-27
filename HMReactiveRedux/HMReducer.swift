//
//  HMReducer.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Holmusk. All rights reserved.
//

/// Represent a reducer that takes an action and a state to produce another
/// state.
public typealias HMReducer<State> = (State, HMActionType) -> State
