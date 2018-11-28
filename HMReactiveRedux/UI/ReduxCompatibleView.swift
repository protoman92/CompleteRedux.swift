//
//  ReduxCompatibleView.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/28/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import UIKit

/// A view that conforms to this protocol can receive state/dispatch props
/// and subscribe to state changes.
public protocol ReduxCompatibleViewType: class {
  associatedtype PropsConnector: ReduxConnectorType
  associatedtype StateProps
  associatedtype DispatchProps
  typealias StaticProps = StaticPropsContainer<PropsConnector, DispatchProps>
  typealias VariableProps = VariablePropsContainer<StateProps>
  
  var stateSubscriberId: String { get }
  var staticProps: StaticProps? { get set }
  var variableProps: VariableProps? { get set }
}

public extension ReduxCompatibleViewType where Self: UIViewController {
  public var stateSubscriberId: String {
    return self.restorationIdentifier ?? String(describing: self)
  }
}

public extension ReduxCompatibleViewType where Self: UIView {
  public var stateSubscriberId: String {
    return self.accessibilityIdentifier ?? String(describing: self)
  }
}

