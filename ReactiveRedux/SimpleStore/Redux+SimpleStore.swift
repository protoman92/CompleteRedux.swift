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
    
    private var _state: State
    private let _reducer: Reducer<State>
    private var _subscribers: [String : StateCallback<State>]
    private var _lock: pthread_rwlock_t
    
    private init(_ initialState: State, _ reducer: @escaping Reducer<State>) {
      self._state = initialState
      self._reducer = reducer
      self._subscribers = [:]
      self._lock = pthread_rwlock_t()
      pthread_rwlock_init(&self._lock, nil)
    }
    
    deinit {pthread_rwlock_destroy(&self._lock)}
    
    /// Get the last reduced state in a thread-safe manner.
    public var lastState: LastState<State> {
      return {self.access {self._state}}
    }
    
    /// Reduce the action to produce a new state and broadcast this state to
    /// all subscribers.
    public var dispatch: Redux.Store.Dispatch {
      return {action in
        self.modify {self._state = self._reducer(self._state, action)}
        self.access {self._subscribers.forEach({$0.value(self._state)})}
      }
    }
    
    /// Subscribe to state updates and immediately receive the latest state.
    /// On unsubscription, remove the subscriber.
    public var subscribeState: Subscribe<State> {
      return {subscriberId, callback in
        self.modify {self._subscribers[subscriberId] = callback}
        
        /// Broadcast the latest state to this subscriber.
        self.access {callback(self._state)}
        
        return Subscription {
          self.modify {self._subscribers.removeValue(forKey: subscriberId)}
        }
      }
    }
    
    /// Access a property in a thread-safe manner.
    private func access<T>(_ fn: () -> T) -> T {
      pthread_rwlock_rdlock(&self._lock)
      defer { pthread_rwlock_unlock(&self._lock) }
      return fn()
    }
    
    /// Modify a property in a thread-safe manner.
    private func modify(_ fn: () -> Void) {
      pthread_rwlock_wrlock(&self._lock)
      defer { pthread_rwlock_unlock(&self._lock) }
      fn()
    }
  }
}
