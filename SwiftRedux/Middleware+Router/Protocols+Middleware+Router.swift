//
//  Protocols+Middleware+Router.swift
//  SwiftRedux
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Implement this protocol to represent a navigatable screen. Usually we would
/// use an enum such as the following:
///
///     enum Screen: RouterScreenType {
///       case login
///       case dashboard
///     }
public protocol RouterScreenType: ReduxActionType {}

/// Implement this protocol to handle in-app navigations. We can pass in the
/// top navigation controller and, depending on the screen, go to the page
/// associated with that screen or replace the whole stack:
///
///     enum Screen: RouterScreenType {
///       case login
///       case dashboard
///     }
///
///     struct NavigationRouter: ReduxRouterType {
///       private let controller: UINavigationController
///
///       init(_ controller: UINavigationController) {
///         self.controller = controller
///       }
///
///       func navigate(_ screen: Screen) {
///         switch screen {
///           case .login:
///             // Go to login screen using nav controller.
///           case .dashboard:
///             // Go to dashboard screen using nav controller.
///         }
///       }
///     }
///
public protocol ReduxRouterType {
  
  /// The app-specific screen implementation for this router.
  associatedtype Screen: RouterScreenType
  
  /// Navigate to a screen.
  ///
  /// - Parameter screen: A Screen instance.
  func navigate(_ screen: Screen)
}
