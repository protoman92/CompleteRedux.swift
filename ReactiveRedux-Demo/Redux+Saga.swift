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
    return Redux.Saga.Effect<State, Any>
      .put(.just(true), actionCreator: AppRedux.Action.progress)
      .then(.call(with: .just(input), callCreator: Api.performAutocomplete))
      .asInput(for: {.put($0, actionCreator: AppRedux.Action.texts)})
      .then(.put(.just(false), actionCreator: AppRedux.Action.progress))
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
