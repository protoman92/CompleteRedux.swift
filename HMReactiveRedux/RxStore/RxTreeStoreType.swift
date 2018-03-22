//
//  RxTreeReduxStoreType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxSwift

/// Classes that implement this protocol should act as a redux-compliant store.
public protocol RxTreeStoreType: ReduxStoreType {
  associatedtype State: TreeStateType

  /// Trigger an action.
  func actionTrigger() -> AnyObserver<Action?>

  /// Subscribe to this stream to receive state notifications.
  func stateStream() -> Observable<State>
}

public extension RxTreeStoreType {

  /// Create a state stream that builds up from an initial state.
  ///
  /// - Parameters:
  ///   - actionTrigger: The action trigger Observable.
  ///   - initialState: The initial state.
  ///   - mainReducer: A Reducer function.
  /// - Returns: An Observable instance.
  public func createState<O>(_ actionTrigger: O,
                             _ initialState: State,
                             _ mainReducer: @escaping ReduxReducer<State>)
    -> Observable<State> where
    O: ObservableConvertibleType, O.E == ReduxActionType
  {
    return actionTrigger.asObservable()
      .scan(initialState, accumulator: mainReducer)
  }
}

public extension RxTreeStoreType {
  public func dispatch<S>(_ actions: S) where S: Sequence, S.Element == Action {
    let trigger = actionTrigger()
    actions.forEach({trigger.onNext($0)})
  }
}
