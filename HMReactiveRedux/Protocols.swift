//
//  Protocols.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/21/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import RxSwift
import SwiftFP

/// Classes that implement this protocol should represent possible actions that
/// can be passed to a reducer.
///
/// Ideally, an app should define an enum for this purpose, so that it can pass
/// data as enum arguments.
public protocol ReduxActionType {}

/// Represent a reducer that takes an action and a state to produce another
/// state.
public typealias ReduxReducer<State> = (State, ReduxActionType) -> State

/// This represents a Redux store that can dispatch events.
public protocol ReduxStoreType {
  typealias Action = ReduxActionType
  associatedtype State
  
  /// Get the last state instance.
  var lastState: Try<State> { get }
  
  /// Dispatch some actions and notify listeners.
  ///
  /// - Parameter actions: A Sequence of Action.
  func dispatch<S>(_ actions: S) where S: Sequence, S.Element == Action
}

public extension ReduxStoreType {
  
  /// Convenience method to dispatch some actions.
  ///
  /// - Parameter actions: A Sequence of Action.
  public func dispatch<S>(_ actions: S) where S: Sequence, S.Element: Action {
    let mapped: [Action] = actions.map({$0})
    dispatch(mapped)
  }
  
  /// Convenience method to dispatch some actions.
  ///
  /// - Parameter actions: Varargs of Redux actions.
  public func dispatch(_ actions: Action...) {
    dispatch(actions)
  }
}

/// Classes that implement this protocol should act as a redux-compliant store.
public protocol RxTreeStoreType: ReduxStoreType where State: TreeStateType {
  
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

/// Convenience typealias for a concurrent generic dispatch store.
public typealias ConcurrentGenericDispatchStore<State> =
  ConcurrentDispatchStore<State, String, State>

public typealias ConcurrentTreeDispatchStore<V> =
  ConcurrentDispatchStore<TreeState<V>, (String, String), Try<V>>

public typealias ReduxCallback<T> = (T) throws -> Void

/// Represents a dispatch-based Redux store.
public protocol DispatchReduxStoreType: ReduxStoreType {
  
  /// Use this to type-check registery information. For e.g., generic dispatch
  /// store (with custom state) should only define this as String. This must
  /// always contain the registrant's id.
  associatedtype Registry
  
  /// Use this to type-check callback values.
  associatedtype CBValue
  
  /// Register a callback based on registry information.
  ///
  /// - Parameters:
  ///   - info: A RegistryInfo instance.
  ///   - callback: A Callback function.
  func register(_ info: Registry, _ callback: @escaping ReduxCallback<CBValue>)
  
  /// Unregister all callbacks for some ids.
  ///
  /// - Parameter ids: The registrant's ids.
  /// - Returns: An Int value indicating the number of removed callbacks.
  func unregister<S>(_ ids: S) -> Int where S: Sequence, S.Element == String
}

public extension DispatchReduxStoreType {
  
  /// Convenience method to unregister callbacks for some ids.
  ///
  /// - Parameter ids: Varargs of ids.
  /// - Returns: An Int value indicating the number of removed callbacks.
  public func unregister(_ ids: String...) -> Int {
    return unregister(ids)
  }
}

/// Represents a generic dispatch store with custom state.
public protocol GenericDispatchStoreType: DispatchReduxStoreType where
  Registry == String,
  CBValue == State {}

#if DEBUG
/// If the build is in debug, use this to check a ping action's state (i.e.
/// actions used to dispatch events, but whose state should not be persisted
/// to the global state - these actions should have a counter action that must
/// be dispatched right after to clear the relevant state values).
public protocol PingActionCheckerType {
  
  /// Check whether the relevant state values have been cleared.
  ///
  /// - Parameter action: A ReduxActionType instance.
  /// - Returns: A Bool value.
  func checkPingActionCleared(_ action: ReduxActionType) -> Bool
}
#endif

/// Represents a Tree-based dispatch store.
public protocol TreeDispatchStoreType: DispatchReduxStoreType where
  State == TreeState<Value>,
  Registry == (String, String),
  CBValue == Try<Value>
{
  associatedtype Value
}
