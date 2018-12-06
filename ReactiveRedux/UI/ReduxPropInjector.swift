//
//  ReduxPropInjector.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 11/27/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit

/// Inject views with state/action props, similar to how React.js performs
/// connect.
public protocol ReduxPropInjectorType {
  associatedtype State
  
  /// Inject state/action props into a compatible view controller.
  ///
  /// - Parameters:
  ///   - vc: A view controller instance.
  ///   - outProps: An OutProps instance.
  ///   - mapper: A Redux prop mapper.
  /// - Returns: A ReduxSubscription instance.
  @discardableResult
  func injectProps<VC, MP>(controller: VC, outProps: VC.OutProps, mapper: MP.Type)
    -> Redux.Store.Subscription where
    MP: ReduxPropMapperType,
    MP.ReduxView == VC,
    VC: UIViewController,
    VC.ReduxState == State
  
  /// Inject state/action props into a compatible view.
  ///
  /// - Parameters:
  ///   - view: A view instance.
  ///   - outProps: An OutProps instance.
  ///   - mapper: A Redux prop mapper.
  /// - Returns: A ReduxSubscription instance.
  @discardableResult
  func injectProps<V, MP>(view: V, outProps: V.OutProps, mapper: MP.Type)
    -> Redux.Store.Subscription where
    MP: ReduxPropMapperType,
    MP.ReduxView == V,
    V: UIView,
    V.ReduxState == State
}

public extension ReduxPropInjectorType {
  
  /// Convenience method to inject props when the controller also conforms to
  /// the necessary protocols.
  ///
  /// - Parameters:
  ///   - vc: A view controller instance.
  ///   - outProps: An OutProps instance.
  /// - Returns: A ReduxSubscription instance.
  @discardableResult
  public func injectProps<VC>(controller vc: VC, outProps: VC.OutProps)
    -> Redux.Store.Subscription where
    VC: UIViewController,
    VC: ReduxPropMapperType,
    VC.ReduxState == State,
    VC.ReduxView == VC
  {
    return self.injectProps(controller: vc, outProps: outProps, mapper: VC.self)
  }
  
  /// Convenience method to inject props when the view also conforms to the
  /// necessary protocols.
  ///
  /// - Parameters:
  ///   - view: A view instance.
  ///   - outProps: An OutProps instance.
  /// - Returns: A ReduxSubscription instance.
  @discardableResult
  public func injectProps<V>(view: V, outProps: V.OutProps)
    -> Redux.Store.Subscription where
    V: UIView,
    V: ReduxPropMapperType,
    V.ReduxState == State,
    V.ReduxView == V
  {
    return self.injectProps(view: view, outProps: outProps, mapper: V.self)
  }
}
