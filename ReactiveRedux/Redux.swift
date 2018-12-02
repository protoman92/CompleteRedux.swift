//
//  Redux.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/1/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Top-level namespace for Redux that provides crucial functionalities.
public final class Redux {
  
  /// Represent a reducer that takes an action and a state to produce another
  /// state.
  public typealias Reducer<State> = (State, ReduxActionType) -> State
  
  /// Unique id for a subscriber.
  public typealias SubscriberId = String
  
  /// Callback for state subscriptions.
  public typealias StateCallback<State> = (State) -> Void
  
  /// Typealias for the state getter function.
  public typealias LastState<State> = () -> State
  
  /// Typealias for the dispatch function.
  public typealias Dispatch = (ReduxActionType) -> Void
  
  /// Typealias for the state subscribe function. Pass in the subscriber id and
  /// callback function.
  public typealias Subscribe<State> = (
    SubscriberId,
    @escaping StateCallback<State>) -> Redux.Subscription
  
  /// Subscription that can be unsubscribed from. This allows subscribers to
  /// store state to cancel anytime they want.
  public struct Subscription {
    public let unsubscribe: () -> Void
    
    init(_ unsubscribe: @escaping () -> Void) {
      self.unsubscribe = unsubscribe
    }
  }
  
  /// This store delegates all its functionalities to another store. It is
  /// used mainly for its type concreteness.
  public struct DelegateStore<State>: ReduxStoreType {
    public let lastState: LastState<State>
    public let dispatch: Dispatch
    public let subscribeState: Subscribe<State>
    
    public init<S>(store: S) where S: ReduxStoreType, S.State == State {
      self.lastState = store.lastState
      self.dispatch = store.dispatch
      self.subscribeState = store.subscribeState
    }
  }
}
