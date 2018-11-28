//
//  ReduxDeepConnector.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 11/28/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import UIKit

/// Implement this protocol to deep-connect view controllers and views.
public protocol ReduxDeepConnectorType {
  associatedtype Connector: ReduxConnectorType
  
  /// Select the appropriate view controller types to connect.
  ///
  /// - Parameter vc: A UIViewController instance.
  /// - Returns: Store cancellable.
  @discardableResult
  func connect(controller vc: UIViewController) -> Connector.Store.Cancellable?
  
  /// Select the appropriate view types to connect.
  ///
  /// - Parameter vc: A UIView instance.
  /// - Returns: Store cancellable.
  @discardableResult
  func connect(view: UIView) -> Connector.Store.Cancellable?
}

public extension ReduxDeepConnectorType {
  
  /// Connect all child views.
  ///
  /// - Parameter vc: A UIView instance.
  /// - Returns: Store cancellable.
  @discardableResult
  public func connectDeeply(view: UIView) -> Connector.Store.Cancellable? {
    if view is LifecycleView { return nil }
    let cancel = self.connect(view: view)
    view.subviews.forEach({_ = self.connectDeeply(view: $0)})
    return cancel
  }
  
  /// Connect a view controller and all child views.
  ///
  /// - Parameter vc: A UIViewController instance.
  /// - Returns: Store cancellable.
  @discardableResult
  public func connectDeeply(controller vc: UIViewController)
    -> Connector.Store.Cancellable?
  {
    let cancel = self.connect(controller: vc)
    vc.view?.subviews.forEach({_ = self.connectDeeply(view: $0)})
    return cancel
  }
}

