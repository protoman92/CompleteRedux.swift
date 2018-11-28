//
//  ReduxProps.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/28/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

/// Container for state/dispatch props.
public struct ReduxProps<StateProps, DispatchProps> {
  public let state: StateProps?
  public let dispatch: DispatchProps?
  
  init(_ state: StateProps?, _ dispatch: DispatchProps?) {
    self.state = state
    self.dispatch = dispatch
  }
}
