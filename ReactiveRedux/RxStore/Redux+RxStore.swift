//
//  Redux+RxStore.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

public extension Redux {
  
  /// Scan action and reduce to produce state sequentially.
  ///
  /// - Parameters:
  ///   - actionStream: A stream of action.
  ///   - reducer: The reducer function that maps previous state to next state.
  ///   - initialState: Initial state.
  /// - Returns: An Observable instance.
  static func scanReduce<State>(_ actionStream: Observable<ReduxActionType>,
                                _ reducer: @escaping Redux.Reducer<State>,
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
    ///   - mainReducer: A ReduxReducer instance.
    /// - Returns: A RxReduxStore instance.
    public static func create(
      _ initialState: State,
      _ reducer: @escaping Redux.Reducer<State>) -> RxStore<State>
    {
      return RxStore(initialState, reducer)
    }
    
    private let disposeBag: DisposeBag
    private var actionObserver: RxObserver<ReduxActionType>
    private var stateObserver: BehaviorSubject<State>
    private let defaultState: State
    
    private init(_ initialState: State,
                 _ reducer: @escaping Redux.Reducer<State>) {
      self.disposeBag = DisposeBag()
      self.actionObserver = RxObserver(Redux.DefaultAction.noop)
      self.stateObserver = BehaviorSubject(value: initialState)
      self.defaultState = initialState
      
      scanReduce(self.actionObserver.asObservable(), reducer, initialState)
        .subscribe(self.stateObserver)
        .disposed(by: self.disposeBag)
    }
  }
}

extension Redux.RxStore: ReduxStoreType {
  public var dispatch: Redux.Dispatch {
    return self.actionTrigger.onNext
  }
  
  public var subscribeState: Redux.Subscribe<State> {
    return {
      let cancelSignal = PublishSubject<Any?>()
      let cancel: () -> Void = {cancelSignal.onNext(nil)}
      let subscription = Redux.Subscription(cancel)
      
      self.stateObserver
        .takeUntil(cancelSignal)
        .subscribe(onNext: $1)
        .disposed(by: self.disposeBag)
      
      return subscription
    }
  }
}

extension Redux.RxStore: RxReduxStoreType {
  public var lastState: Redux.LastState<State> {
    return {Try({try self.stateObserver.value()}).getOrElse(self.defaultState)}
  }
  
  public var actionTrigger: AnyObserver<ReduxActionType> {
    return self.actionObserver.asObserver()
  }
  
  public var stateStream: Observable<State> {
    return self.stateObserver.asObservable()
  }
  
  var stateTrigger: AnyObserver<State> {
    return self.stateObserver.asObserver()
  }
}

