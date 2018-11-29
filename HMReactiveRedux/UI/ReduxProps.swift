//
//  ReduxProps.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/28/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

public struct StaticReduxProps<Connector: ReduxConnectorType> {
  public let connector: Connector
  let unsubscribe: ReduxUnsubscribe
  
  init(_ connector: Connector, _ unsubscribe: @escaping ReduxUnsubscribe) {
    self.connector = connector
    self.unsubscribe = unsubscribe
  }
}

public struct VariableReduxProps<StateProps, DispatchProps> {
  public let previousState: StateProps
  public let nextState: StateProps
  public let dispatch: DispatchProps
  
  init(_ previousState: StateProps,
       _ nextState: StateProps,
       _ dispatch: DispatchProps) {
    self.previousState = previousState
    self.nextState = nextState
    self.dispatch = dispatch
  }
}
