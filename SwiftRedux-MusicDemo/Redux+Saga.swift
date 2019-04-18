//
//  Redux+Saga.swift
//  ReduxForSwift
//
//  Created by Hai Pham on 12/10/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftRedux

public final class AppSaga {
  
  /// The app's saga branches.
  public static func sagas(_ api: AppRepositoryType) -> [SagaEffect<Any>] {
    return [
      SagaEffects.takeLatest(
        paramExtractor: self.autocompleteParam,
        effectCreator: {self.autocompleteSaga(api, $0)},
        options: TakeOptions.builder().with(debounce: 0.5).build())
    ]
  }
  
  /// Extract the autocomplete query from an action.
  public static func autocompleteParam(_ action: AppAction) -> String? {
    switch action {
    case .updateAutocompleteInput(let input): return input
    default: return nil
    }
  }
  
  public static func autocompleteSaga(_ api: AppRepositoryType, _ input: String)
    -> SagaEffect<Any>
  {
    return SagaEffects
      .put(true, actionCreator: AppAction.updateAutocompleteProgress)
      .then(input).call(api.searchITunes)
      .delay(bySeconds: 1)
      .put(AppAction.updateITunesResults, usingQueue: .global(qos: .background))
      .catchError({_ in ()})
      .then(false)
      .put(AppAction.updateAutocompleteProgress)
  }
  
  /// Verbose saga to demonstrate full use of helper functions.
  public static func verboseAutocompleteSaga(_ api: AppRepositoryType, _ input: String)
    -> SagaEffect<Any>
  {
    /// Create an Effect wrapper from the input string.
    let inputEffect = SagaEffects.just(input)
    
    /// Create a CallEffect to invoke the search API on the query.
    let callEffect = SagaEffects.call(with: inputEffect, callCreator: api.searchITunes)
    
    /// Create a PutEffect to deposit search results into the Redux Store.
    return SagaEffects.put(callEffect, actionCreator: AppAction.updateITunesResults)
  }
}
