//
//  RxUtils.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 11/25/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

/// Scan action and reduce to produce state sequentially.
///
/// - Parameters:
///   - actionStream: A stream of action.
///   - reducer: The reducer function that maps previous state to next state.
///   - initialState: Initial state.
/// - Returns: An Observable instance.
func scanReduce<State>(_ actionStream: Observable<ReduxActionType>,
                       _ reducer: @escaping ReduxReducer<State>,
                       _ initialState: State) -> Observable<State> {
  return actionStream.scan(initialState, accumulator: reducer)
}
