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
    let progressOn = Redux.Saga.Effect<State, Any>
      .put(.just(true), actionCreator: AppRedux.Action.progress)
    
    let callAutocomplete = Redux.Saga.Effect.call(
      param: Redux.Saga.Effect<State, String>.just(input),
      callCreator: Api.performAutocomplete)
    
    let combined = Redux.Saga.Effect.sequentialize(progressOn, callAutocomplete)
    
    let putResult = Redux.Saga.Effect<State, Any>
      .put(combined, actionCreator: AppRedux.Action.texts)
    
    let progressOff = Redux.Saga.Effect<State, Any>
      .put(.just(false), actionCreator: AppRedux.Action.progress)
    
    return Redux.Saga.Effect.sequentialize(putResult, progressOff)
  }
  
  static func sagas() -> [Redux.Saga.Effect<State, Any>] {
    return [
      Redux.Saga.Effect.takeLatest(
        actionType: AppRedux.Action.self,
        paramExtractor: extractAutocompleteInput,
        effectCreator: autocompleteSaga)
    ]
  }
}
