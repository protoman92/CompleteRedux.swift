//
//  ReduxPropMapper.swift
//  SwiftRedux
//
//  Created by Hai Pham on 11/28/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Prop mapper that maps state/dispatch to Redux props. Redux props include
/// StateProps (information to populate the UI) and ActionProps (set of actions
/// to handle UI interactions).
///
/// The methods defined here are static because we want to restrict usage of
/// internal state as much as possible. We should only use whatever data that
/// are passed in via parameters to create props (e.g. state, outProps).
public protocol PropMapperType: class {
  associatedtype PropContainer: PropContainerType
  
  /// The app-specific state type.
  typealias ReduxState = PropContainer.ReduxState
  
  /// The Redux view's OutProps.
  typealias OutProps = PropContainer.OutProps
  
  /// The Redux view's StateProps.
  typealias StateProps = PropContainer.StateProps
  
  /// The Redux view's ActionProps.
  typealias ActionProps = PropContainer.ActionProps
  
  /// Map ReduxState to StateProps.
  ///
  /// - Parameters:
  ///   - state: A ReduxState instance.
  ///   - outProps: An OutProps instance.
  /// - Returns: A StateProps instance.
  static func mapState(state: ReduxState, outProps: OutProps) -> StateProps
  
  /// Map a Redux dispatch to action props.
  ///
  /// - Parameters:
  ///   - dispatch: A Dispatch instance.
  ///   - state: A ReduxState instance.
  ///   - outProps: An OutProps instance.
  /// - Returns: An ActionProps instance.
  static func mapAction(dispatch: @escaping ReduxDispatcher,
                        state: ReduxState,
                        outProps: OutProps) -> ActionProps
  
  /// Compare previous/next StateProps.
  ///
  /// - Parameters:
  ///   - lhs: Previous StateProps.
  ///   - rhs: Next StateProps.
  /// - Returns: A Bool instance.
  static func compareState(lhs: StateProps?, rhs: StateProps?) -> Bool
}

/// We should make state props conform to Equatable, so that some defaults
/// can be implemented.
public extension PropMapperType where StateProps: Equatable {
  public static func compareState(lhs: StateProps?, rhs: StateProps?) -> Bool {
    return lhs == rhs
  }
}
