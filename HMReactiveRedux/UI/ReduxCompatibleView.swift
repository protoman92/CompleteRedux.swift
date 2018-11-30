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
  associatedtype PropsConnector: ReduxPropInjectorType
  associatedtype StateProps
  associatedtype DispatchProps
  typealias StaticProps = StaticPropsCt<PropsConnector>
  typealias VariableProps = VariablePropsCt<StateProps, DispatchProps>
  
  /// This prop container includes static dependencies that can be used to
  /// wire up child views/view controllers.
  var staticProps: StaticProps? { get set }
  
  /// This prop container includes variable state/dispatch props.
  var variableProps: VariableProps? { get set }
}
