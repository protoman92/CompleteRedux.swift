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
  associatedtype StateProps
  associatedtype DispatchProps
  typealias Props = ReduxProps<StateProps, DispatchProps>
  
  var stateSubscriberId: String { get }
  var reduxProps: Props? { get set }
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

