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
  associatedtype PropInjector: ReduxPropInjectorType
  
  /// This props represents data that is directly related to the parent view/
  /// view controller. For example, when we inject a table view cell, this may
  /// contain the index of that cell - which will be used to create variable
  /// props.
  associatedtype OutProps
  
  /// This represents variable state that can be used to update the UI.
  associatedtype StateProps
  
  /// This represents a set of actions that can be used to handle user
  /// interactions.
  associatedtype DispatchProps
  
  typealias StaticProps = StaticPropsCt<PropInjector>
  typealias VariableProps = VariablePropsCt<StateProps, DispatchProps>
  
  /// This prop container includes static dependencies that can be used to
  /// wire up child views/view controllers.
  var staticProps: StaticProps? { get set }
  
  /// This prop container includes variable state/dispatch props.
  var variableProps: VariableProps? { get set }
}

public extension ReduxCompatibleViewType where Self: ReduxPropMapperType {
  public typealias ReduxView = Self
}
