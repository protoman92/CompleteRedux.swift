//
//  Redux+Saga.swift
//  ReactiveRedux-Demo
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import ReactiveRedux
import SafeNest

final class AppReduxSaga {
  typealias State = SafeNest
  
  static func extractAutocompleteInput(_ action: AppRedux.Action) -> String? {
    switch action {
    case .string(let input): return input
    default: return nil
    }
  }
  
  static func autocompleteSaga(_ input: String) -> Redux.Saga.Effect<State, Any> {
    let call = Redux.Saga.Effects.call(
      param: Redux.Saga.Effects.just(input, forState: State.self),
      callCreator: Api.performAutocomplete)
    
    return Redux.Saga.Effects.put(call, actionCreator: AppRedux.Action.texts)
  }
  
  static func sagas() -> [Redux.Saga.Effect<State, Any>] {
    return [
      Redux.Saga.Effects.takeLatest(
        actionType: AppRedux.Action.self,
        paramExtractor: extractAutocompleteInput,
        effectCreator: autocompleteSaga)
    ]
  }
}
