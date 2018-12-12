//
//  Redux+SimpleStore.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/12/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

extension Redux.Store {

  /// Simple store that keeps track of subscribers in a Dictionary. This store
  /// is thread-safe.
  public final class SimpleStore<State>: ReduxStoreType {

    /// Create a simple store instance with an initial state and reducer.
    ///
    /// - Parameters:
    ///   - initialState: The initial store state.
    ///   - reducer: The main reducer instance.
    /// - Returns: A simple store instance.
    public static func create(
      _ initialState: State,
      _ reducer: @escaping Reducer<State>) -> SimpleStore<State>
    {
      return .init(initialState, reducer)
    }
    
    private let _lock: ReadWriteLockType
    private var _state: State
    private let _reducer: Reducer<State>
    private var _subscribers: [String : StateCallback<State>]
    
    private init(_ initialState: State, _ reducer: @escaping Reducer<State>) {
      self._lock = Redux.ReadWriteLock()
      self._state = initialState
      self._reducer = reducer
      self._subscribers = [:]
    }
    
    /// Get the last reduced state in a thread-safe manner.
    public var lastState: LastState<State> {
      return {self._lock.access {self._state}.getOrElse(self._state)}
    }
    
    /// Reduce the action to produce a new state and broadcast this state to
    /// all subscribers.
    public var dispatch: Redux.Store.Dispatch {
      return {action in
        self._lock.modify {self._state = self._reducer(self._state, action)}
        self._lock.access {self._subscribers.forEach({$0.value(self._state)})}
      }
    }
    
    /// Subscribe to state updates and immediately receive the latest state.
    /// On unsubscription, remove the subscriber.
    public var subscribeState: Subscribe<State> {
      return {subscriberId, callback in
        self._lock.modify {self._subscribers[subscriberId] = callback}
        
        /// Broadcast the latest state to this subscriber.
        self._lock.access {callback(self._state)}
        
        return Subscription {
          self._lock.modify {self._subscribers.removeValue(forKey: subscriberId)}
        }
      }
    }
  }
}
