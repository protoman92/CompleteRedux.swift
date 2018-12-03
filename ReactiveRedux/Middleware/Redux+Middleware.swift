//
//  Redux+Middleware.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux.Middleware {
  
  /// Convenience container to expose basic store functionalities to allow
  /// middlewares.
  public struct Input<State> {
    public let lastState: Redux.Store.LastState<State>
    public let dispatch: Redux.Store.Dispatch
    
    init(_ lastState: @escaping Redux.Store.LastState<State>,
         _ dispatch: @escaping Redux.Store.Dispatch) {
      self.lastState = lastState
      self.dispatch = dispatch
    }
  }
  
  /// Function that maps one dispatch to another.
  public typealias DispatchMapper =
    (@escaping Redux.Store.Dispatch) -> Redux.Store.Dispatch
  
  /// Redux store middleware which has access to the store's functionalities.
  public typealias Middleware<State> = (Input<State>) -> DispatchMapper
  
  /// Apply a series of middlewares to a redux store.
  ///
  /// - Parameter middlewares: An Array of middlewares.
  /// - Returns: A Store instance.
  public static func applyMiddlewares<Store>(
    _ middlewares: Middleware<Store.State>...)
    -> (Store) -> Redux.Store.DelegateStore<Store.State> where
    Store: ReduxStoreType
  {
    return {store in
      let combined: Middleware<Store.State> = middlewares.reversed().reduce(
        {_ in {_ in store.dispatch}},
        {(a, b) in {input in {b(input)(a(input)($0))}}}
      )

      let input = Input(store.lastState, store.dispatch)
      let dispatch = combined(input)(store.dispatch)
      let enhanced = Redux.Store.EnhancedStore(store, dispatch)
      return Redux.Store.DelegateStore(enhanced)
    }
  }
}
