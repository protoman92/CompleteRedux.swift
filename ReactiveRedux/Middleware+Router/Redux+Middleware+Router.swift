//
//  Redux+Middleware+Router.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux.Middleware {

  /// Screen navigation function.
  public typealias ReduxNavigate<Screen> = (Screen) -> Void
  
  /// Middleware to handle router navigation. After we hook this middleware
  /// up, we can perform navigations by dispatching screens like so:
  ///
  /// enum Screen: ReduxNavigationScreenType {
  ///   case login
  ///   case dashboard
  /// }
  ///
  /// ...
  /// dispatch(Screen.login)
  /// dispatch(Screen.password)
  public struct Router<State, Screen: ReduxNavigationScreenType>:
    ReduxMiddlewareProviderType
  {
    private let _navigate: ReduxNavigate<Screen>
    
    public init<R>(router: R) where R: ReduxRouterType, R.Screen == Screen {
      self._navigate = router.navigate
    }
    
    public var middleware: Middleware<State> {
      return {_ in
        {
          dispatch in
          {
            dispatch($0)
            
            if let screen = $0 as? Screen {
              // Force-navigate on the main thread.
              DispatchQueue.main.async {self._navigate(screen)}
            }
          }
        }
      }
    }
  }
}
