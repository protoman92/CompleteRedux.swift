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
  
  /// Function that maps one dispatch to another.
  public typealias DispatchMapper = (@escaping Dispatch) -> Dispatch
  
  /// Redux store middleware which has access to the store's functionalities.
  public typealias Middleware<State> = (MiddlewareInput<State>) -> DispatchMapper
  
  /// Apply a series of middlewares to a redux store.
  ///
  /// - Parameter middlewares: An Array of middlewares.
  /// - Returns: A Store instance.
  public static func applyMiddlewares<Store>(
    _ middlewares: Middleware<Store.State>...)
    -> (Store) -> DelegateStore<Store.State> where
    Store: ReduxStoreType
  {
    return {store in
      let combined: Middleware<Store.State> = middlewares.reversed().reduce(
        {_ in {_ in store.dispatch}},
        {(a, b) in {input in {b(input)(a(input)($0))}}}
      )

      let input = MiddlewareInput(store.lastState, store.dispatch)
      let dispatch = combined(input)(store.dispatch)
      let enhancedStore = EnhancedStore(store: store, dispatch: dispatch)
      return DelegateStore(store: enhancedStore)
    }
  }
}
