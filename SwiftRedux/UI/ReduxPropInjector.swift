//
//  ReduxPropInjector.swift
//  SwiftRedux
//
//  Created by Hai Pham on 11/27/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import UIKit

/// Inject views with state/action props, similar to how React.js performs
/// connect.
public protocol ReduxPropInjectorType {
  
  /// The app-specific state type.
  associatedtype State
  
  /// Inject state/action props into a compatible view controller.
  ///
  /// - Parameters:
  ///   - vc: A view controller instance.
  ///   - outProps: An OutProps instance.
  ///   - mapper: A Redux prop mapper.
  func injectProps<VC, MP>(controller: VC, outProps: VC.OutProps, mapper: MP.Type) where
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
  func injectProps<V, MP>(view: V, outProps: V.OutProps, mapper: MP.Type) where
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
  public func injectProps<VC>(controller vc: VC, outProps: VC.OutProps) where
    VC: UIViewController,
    VC: ReduxPropMapperType,
    VC.ReduxState == State,
    VC.ReduxView == VC
  {
    self.injectProps(controller: vc, outProps: outProps, mapper: VC.self)
  }
  
  /// Convenience method to inject props when the view also conforms to the
  /// necessary protocols.
  ///
  /// - Parameters:
  ///   - view: A view instance.
  ///   - outProps: An OutProps instance.
  /// - Returns: A ReduxSubscription instance.
  public func injectProps<V>(view: V, outProps: V.OutProps) where
    V: UIView,
    V: ReduxPropMapperType,
    V.ReduxState == State,
    V.ReduxView == V
  {
    self.injectProps(view: view, outProps: outProps, mapper: V.self)
  }
}
