//
//  ReduxPropMapper.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/28/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

/// Prop mapper that maps state/dispatch to redux props.
public protocol ReduxPropMapperType {
  associatedtype State
  associatedtype StateProps
  associatedtype DispatchProps
  
  func map(state: State) -> StateProps?
  func map(dispatch: @escaping ReduxDispatch) -> DispatchProps?
  static func compareState(lhs: StateProps?, rhs: StateProps?) -> Bool
}

public extension ReduxPropMapperType where StateProps: Equatable {
  public static func compareState(lhs: StateProps?, rhs: StateProps?) -> Bool {
    return lhs == rhs
  }
}
