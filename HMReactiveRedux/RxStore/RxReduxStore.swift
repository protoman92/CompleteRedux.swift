//
//  RxReduxStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

/// Classes that implement this protocol should act as a redux-compliant store.
public protocol RxReduxStoreType: ReduxStoreType {
  
  /// Trigger an action.
  var actionTrigger: AnyObserver<Action> { get }
  
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
  private var actionObserver: RxReduxObserver<Action>
  private var stateObserver: BehaviorSubject<State>

  private init(_ initialState: State,
               _ reducer: @escaping ReduxReducer<State>) {
    self.disposeBag = DisposeBag()
    self.actionObserver = RxReduxObserver<Action>(DefaultRedux.Action.noop)
    self.stateObserver = BehaviorSubject(value: initialState)
    
    scanReduce(self.actionObserver.asObservable(), reducer, initialState)
      .subscribe(self.stateObserver)
      .disposed(by: self.disposeBag)
  }
}

extension RxReduxStore: ReduxStoreType {
  public func dispatch(_ action: Action) {
    self.actionTrigger.onNext(action)
  }
  
  public func subscribeState(subscriberId: String,
                             callback: @escaping (State) -> Void)
    -> ReduxUnsubscribe
  {
    let cancelSignal = PublishSubject<Any?>()
    let cancel: ReduxUnsubscribe = {cancelSignal.onNext(nil)}
    
    self.stateObserver
      .takeUntil(cancelSignal)
      .subscribe(onNext: callback)
      .disposed(by: self.disposeBag)
    
    return cancel
  }
}

extension RxReduxStore: RxReduxStoreType {
  public var lastState: Try<State> {
    return Try({try self.stateObserver.value()})
  }

  public var actionTrigger: AnyObserver<Action> {
    return self.actionObserver.asObserver()
  }

  public var stateStream: Observable<State> {
    return self.stateObserver.asObservable()
  }
  
  var stateTrigger: AnyObserver<State> {
    return self.stateObserver.asObserver()
  }
}
