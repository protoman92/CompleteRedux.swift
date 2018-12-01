//
//  RxReduxStore.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Classes that implement this protocol should act as a redux-compliant store.
public protocol RxReduxStoreType: ReduxStoreType {
  
  /// Trigger an action.
  var actionTrigger: AnyObserver<ReduxActionType> { get }
  
  /// Subscribe to this stream to receive state notifications.
  var stateStream: Observable<State> { get }
}

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
  public static func create(
    _ initialState: State,
    _ reducer: @escaping ReduxReducer<State>) -> RxReduxStore<State>
  {
    return RxReduxStore(initialState, reducer)
  }

  private let disposeBag: DisposeBag
  private var actionObserver: RxReduxObserver<ReduxActionType>
  private var stateObserver: BehaviorSubject<State>
  private let defaultState: State

  private init(_ initialState: State,
               _ reducer: @escaping ReduxReducer<State>) {
    self.disposeBag = DisposeBag()
    self.actionObserver = RxReduxObserver(DefaultRedux.Action.noop)
    self.stateObserver = BehaviorSubject(value: initialState)
    self.defaultState = initialState
    
    scanReduce(self.actionObserver.asObservable(), reducer, initialState)
      .subscribe(self.stateObserver)
      .disposed(by: self.disposeBag)
  }
}

extension RxReduxStore: ReduxStoreType {
  public var dispatch: ReduxDispatch {
    return self.actionTrigger.onNext
  }
  
  public var subscribeState: ReduxSubscribe<State> {
    return {
      let cancelSignal = PublishSubject<Any?>()
      let cancel: () -> Void = {cancelSignal.onNext(nil)}
      let subscription = ReduxSubscription(cancel)
      
      self.stateObserver
        .takeUntil(cancelSignal)
        .subscribe(onNext: $1)
        .disposed(by: self.disposeBag)
      
      return subscription
    }
  }
}

extension RxReduxStore: RxReduxStoreType {
  public var lastState: State {
    do {
      return try self.stateObserver.value()
    } catch {
      return self.defaultState
    }
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
