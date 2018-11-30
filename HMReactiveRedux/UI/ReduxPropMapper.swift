//
//  ReduxPropMapper.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/28/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

/// Prop mapper that maps state/dispatch to redux props. Redux props include
/// StateProps (information to populate the UI) and DispatchProps (set of
/// actions to handle UI interactions).
public protocol ReduxPropMapperType: class {
  associatedtype ReduxState
  associatedtype StateProps
  associatedtype DispatchProps
  
  /// Map ReduxState to StateProps.
  ///
  /// - Parameter state: A ReduxState instance.
  /// - Returns: A StateProps instance.
  func map(state: ReduxState) -> StateProps
  
  /// Map a Redux dispatch to DispatchProps.
  ///
  /// - Parameter dispatch: A ReduxDispatch instance.
  /// - Returns: A DispatchProps instance.
  func map(dispatch: @escaping ReduxDispatch) -> DispatchProps
  
  /// Compare previous/next StateProps.
  ///
  /// - Parameters:
  ///   - lhs: Previous StateProps.
  ///   - rhs: Next StateProps.
  /// - Returns: A Bool instance.
  static func compareState(lhs: StateProps?, rhs: StateProps?) -> Bool
}

public extension ReduxPropMapperType where StateProps: Equatable {
  public static func compareState(lhs: StateProps?, rhs: StateProps?) -> Bool {
    return lhs == rhs
  }
}
