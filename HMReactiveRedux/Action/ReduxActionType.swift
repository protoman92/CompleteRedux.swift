//
//  ReduxActionType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

/// Classes that implement this protocol should represent possible actions that
/// can be passed to a reducer.
///
/// Ideally, an app should define an enum for this purpose, so that it can pass
/// data as enum arguments.
public protocol ReduxActionType {}

/// This protocol marks an action as a "ping" action. Sometimes we want to
/// perform one-off tasks (such as show an error), but do not want to retain
/// whatever the value at the action's value path.
///
/// For e.g., an object pushes an error onto the global state, and a view
/// listens to the error storage and displays a message on UI. The next time
/// another view subscribes to the error storage, it should not know what
/// error was last displayed. For such actions, return false.
public protocol ReduxPingActionType: ReduxActionType {

  /// We assume that ping actions must deposit something in the global state
  /// for all listeners to be notified of.
  var pingValuePath: String { get }
}
