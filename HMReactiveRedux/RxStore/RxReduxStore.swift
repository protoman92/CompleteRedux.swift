//
//  RxReduxStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// A Redux-compliant store. Since this store is used for UI-related work, it
/// should operation on the main thread.
public struct RxReduxStore<State> {

  /// Create a redux store that only receives and delivers events on the main
  /// thread.
  ///
  /// - Parameters:
  ///   - initialState: A State instance.
  ///   - mainReducer: A ReduxReducer instance.
  /// - Returns: A RxReduxStore instance.
  public static func createInstance(
    _ initialState: State,
    _ reducer: @escaping ReduxReducer<State>) -> RxReduxStore<State>
  {
    return RxReduxStore(initialState, reducer)
  }

  private let disposeBag: DisposeBag
  private var actionObserver: RxReduxObserver<Action>
  private var stateObserver: BehaviorSubject<State>

  private init(_ initialState: State,
               _ reducer: @escaping ReduxReducer<State>) {
    self.disposeBag = DisposeBag()
    self.actionObserver = RxReduxObserver<Action>(DefaultRedux.Action.noop)
    self.stateObserver = BehaviorSubject(value: initialState)
    
    self.actionObserver.asObservable()
      .scan(initialState, accumulator: reducer)
      .subscribe(self.stateObserver)
      .disposed(by: self.disposeBag)
  }
}

extension RxReduxStore: ReduxStoreType {
  public func dispatch(_ action: Action) {
    self.actionTrigger().onNext(action)
  }
}

extension RxReduxStore: RxReduxStoreType {
  public var lastState: Try<State> {
    return Try({try self.stateObserver.value()})
  }

  public func actionTrigger() -> AnyObserver<Action> {
    return self.actionObserver.asObserver()
  }

  public func stateStream() -> Observable<State> {
    return self.stateObserver.asObservable()
  }
}
