//
//  Redux+Middleware+Router.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux.Middleware {

  /// Top-level namespace for Redux Router middleware.
  public final class Router {
    init() {}

    /// Screen navigation function.
    public typealias Navigate<Screen> = (Screen) -> Void
    
    /// Middleware to handle router navigation. After we hook this middleware
    /// up, we can perform navigations by dispatching screens like so:
    ///
    ///     enum Screen: ReduxNavigationScreenType {
    ///       case login
    ///       case dashboard
    ///     }
    ///
    ///     ...
    ///     dispatch(Screen.login)
    ///     dispatch(Screen.password)
    public struct Provider<State, Screen: ReduxNavigationScreenType>:
      ReduxMiddlewareProviderType
    {
      private let _navigate: Navigate<Screen>
      
      public init<R>(router: R) where R: ReduxRouterType, R.Screen == Screen {
        self._navigate = router.navigate
      }
      
      public var middleware: Middleware<State> {
        return {_ in
          {wrapper in
            let newWrapperId = "\(wrapper.identifier)-router"
            
            return Redux.Store.DispatchWrapper(newWrapperId) {action in
              wrapper.dispatch(action)
              
              if let screen = action as? Screen {
                // Force-navigate on the main thread.
                DispatchQueue.main.async {self._navigate(screen)}
              }
            }
          }
        }
      }
    }
  }
}
