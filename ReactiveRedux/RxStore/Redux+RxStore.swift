//
//  Redux+RxStore.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

public extension Redux.Store {
  
  /// Scan action and reduce to produce state sequentially.
  ///
  /// - Parameters:
  ///   - actionStream: A stream of action.
  ///   - reducer: The reducer function that maps previous state to next state.
  ///   - initialState: Initial state.
  /// - Returns: An Observable instance.
  static func scanReduce<State>(_ actionStream: Observable<ReduxActionType>,
                                _ reducer: @escaping Reducer<State>,
                                _ initialState: State) -> Observable<State> {
    return actionStream
      .observeOn(MainScheduler.instance)
      .scan(initialState, accumulator: reducer)
  }
  
  /// A Redux-compliant store. Since this store is used for UI-related work, it
  /// should operation on the main thread.
  public struct RxStore<State> {
    
    /// Create a redux store that only receives and delivers events on the main
    /// thread.
    ///
    /// - Parameters:
    ///   - initialState: A State instance.
    ///   - mainReducer: A Reducer instance.
    /// - Returns: A RxReduxStore instance.
    public static func create(
      _ initialState: State,
      _ reducer: @escaping Reducer<State>) -> RxStore<State>
    {
      return RxStore(initialState, reducer)
    }
    
    private let _disposeBag: DisposeBag
    private var _actionObserver: RxObserver<ReduxActionType>
    private var _stateObserver: BehaviorSubject<State>
    private let _defaultState: State
    
    var stateTrigger: AnyObserver<State> {
      return self._stateObserver.asObserver()
    }
    
    private init(_ initialState: State,
                 _ reducer: @escaping Reducer<State>) {
      self._disposeBag = DisposeBag()
      self._actionObserver = RxObserver(Redux.Preset.Action.noop)
      self._stateObserver = BehaviorSubject(value: initialState)
      self._defaultState = initialState
      
      scanReduce(self._actionObserver.asObservable(), reducer, initialState)
        .subscribe(self._stateObserver)
        .disposed(by: self._disposeBag)
    }
  }
}

extension Redux.Store.RxStore: ReduxStoreType {
  public var dispatch: Redux.Store.Dispatch {
    return self.actionTrigger.onNext
  }
  
  public var subscribeState: Redux.Store.Subscribe<State> {
    return {
      let cancelSignal = PublishSubject<Any?>()
      let cancel: () -> Void = {cancelSignal.onNext(nil)}
      let subscription = Redux.Store.Subscription(cancel)
      
      self._stateObserver
        .takeUntil(cancelSignal)
        .subscribe(onNext: $1)
        .disposed(by: self._disposeBag)
      
      return subscription
    }
  }
}

extension Redux.Store.RxStore: RxReduxStoreType {
  public var lastState: Redux.Store.LastState<State> {
    return {Try({try self._stateObserver.value()}).getOrElse(self._defaultState)}
  }
  
  public var actionTrigger: AnyObserver<ReduxActionType> {
    return self._actionObserver.asObserver()
  }
  
  public var stateStream: Observable<State> {
    return self._stateObserver.asObservable()
  }
}

