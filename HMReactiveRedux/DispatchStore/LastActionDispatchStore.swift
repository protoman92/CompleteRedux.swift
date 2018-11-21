//
//  LastActionDispatchStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 20/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP

/// Wrapper for a dispatch store to track the last action and perform custom
/// asserts, such as checking for ping actions.
public final class LastActionDispatchStore<State, RegistryInfo, CBValue>:
  DispatchReduxStore<State, RegistryInfo, CBValue>
{
  public typealias Store = DispatchReduxStore<State, RegistryInfo, CBValue>

  override public var lastState: Try<State> {
    return store.lastState
  }

  fileprivate let store: Store

  /// Track the last dispatched action.
  fileprivate var lastAction: ReduxActionType?

  #if DEBUG
  fileprivate let issueNotifier: (String) -> Void

  public init(_ store: Store, _ issueNotifier: @escaping (String) -> Void) {
    self.issueNotifier = issueNotifier
    self.store = store
  }

  convenience public init(_ store: Store) {
    #if DEBUG
    self.init(store, {fatalError($0)})
    #else
    self.init(store, {_ in})
    #endif
  }
  #else
  public init(_ store: Store) {
    self.store = store
  }
  #endif

  override public func dispatch(_ action: Action) {
    let lastAction = self.lastAction
    self.store.dispatch(action)
    self.lastAction = action

    #if DEBUG
    let issueNotifier = self.issueNotifier

    /// Check whether the ping action has been cleared, or else throw an error.
    /// To avoid this, ping actions should be dispatched along with their
    /// reset counterparts. For e.g.:
    ///
    ///   store.dispatch(triggerAction, clearAction)
    ///
    /// Because this check only happens once per dispatch batch, the store knows
    /// when to correctly throw an error.
    if let state = store.lastState.value as? PingActionCheckerType {
      if let action = lastAction, !state.checkPingActionCleared(action) {
        issueNotifier("Must clear ping action: \(action)")
      }
    } else {
      issueNotifier("\(State.self) must implement \(PingActionCheckerType.self)")
    }
    #endif
  }

  override public func register(_ info: RegistryInfo, _ callback: @escaping ReduxCallback<CBValue>) {
    self.store.register(info, callback)
  }

  override public func unregister<S>(_ ids: S) -> Int where S: Sequence, S.Element == String {
    return self.store.unregister(ids)
  }
}
