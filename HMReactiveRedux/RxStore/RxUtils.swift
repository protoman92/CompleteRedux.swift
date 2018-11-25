//
//  RxUtils.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/25/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import RxSwift

func scanReduce<State>(_ actionStream: Observable<ReduxActionType>,
                       _ reducer: @escaping ReduxReducer<State>,
                       _ initialState: State) -> Observable<State> {
  return actionStream.scan(initialState, accumulator: reducer)
}
