//
//  ReduxConnectableView.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/28/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import UIKit

/// A view that conforms to this protocol can receive state/dispatch props
/// and subscribe to state changes.
public protocol ReduxConnectableViewType: class {
  associatedtype StateProps
  associatedtype DispatchProps
  typealias ReduxProps = (state: StateProps, dispatch: DispatchProps)
  
  var stateSubscriberId: String { get }
  var reduxProps: ReduxProps? { get set }
}

public extension ReduxConnectableViewType where Self: UIViewController {
  public var stateSubscriberId: String {
    return self.restorationIdentifier ?? String(describing: self)
  }
}

public extension ReduxConnectableViewType where Self: UIView {
  public var stateSubscriberId: String {
    return self.accessibilityIdentifier ?? String(describing: self)
  }
}
