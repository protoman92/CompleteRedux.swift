//
//  ReduxConnectorMapper.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/28/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

/// Connector mapper that maps state/dispatch to redux props.
public protocol ReduxConnectorMapperType {
  associatedtype State
  associatedtype StateProps
  associatedtype DispatchProps
  
  static func map(state: State) -> StateProps
  static func map(dispatch: @escaping ReduxDispatch) -> DispatchProps
  static func compareState(lhs: StateProps, rhs: StateProps) -> Bool
}

public extension ReduxConnectorMapperType where StateProps: Equatable {
  public static func compareState(lhs: StateProps,
                                  rhs: StateProps) -> Bool {
    return lhs == rhs
  }
}
