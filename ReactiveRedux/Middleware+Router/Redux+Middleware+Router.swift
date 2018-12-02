//
//  Redux+Middleware+Router.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux {

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
  public struct RouterMiddleware<State, Screen: ReduxNavigationScreenType>:
    ReduxMiddlewareProviderType
  {
    private let navigate: ReduxNavigate<Screen>
    
    public init<R>(_ router: R) where R: ReduxRouterType, R.Screen == Screen {
      self.navigate = router.navigate
    }
    
    public func wrap(_ input: MiddlewareInput<State>) -> DispatchMapper {
      return {dispatch in
        {
          dispatch($0)
          
          guard let screen = $0 as? Screen else {
            return
          }
          
          // Force-navigate on the main thread.
          DispatchQueue.main.async {self.navigate(screen)}
        }
      }
    }
  }
}
