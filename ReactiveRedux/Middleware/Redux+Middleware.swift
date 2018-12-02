//
//  Redux+Middleware.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux {
  
  /// Convenience container to expose basic store functionalities to allow
  /// middlewares.
  public struct MiddlewareInput<State> {
    public let lastState: LastState<State>
    public let dispatch: Dispatch
    
    init(_ lastState: @escaping LastState<State>,
         _ dispatch: @escaping Dispatch) {
      self.lastState = lastState
      self.dispatch = dispatch
    }
  }
  
  /// Redux store middleware which has access to the store's functionalities.
  public typealias Middleware<State> = (MiddlewareInput<State>) -> Dispatch
  
  /// Apply a series of middlewares to a redux store.
  ///
  /// - Parameter middlewares: An Array of middlewares.
  /// - Returns: A Store instance.
  public static func applyMiddlewares<Store>(
    _ middlewares: Middleware<Store.State>...)
    -> (Store) -> EnhancedStore<Store.State> where
    Store: ReduxStoreType
  {
    return {store in
      let dispatch = middlewares.reversed().reduce(store.dispatch, {
        $1(MiddlewareInput(store.lastState, $0))
      })

      return EnhancedStore(store: store, dispatch: dispatch)
    }
  }
}
