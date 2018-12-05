//
//  Redux+Middleware.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

public extension Redux.Store {
  
  /// Use this tracker to track middleware wrapping with an identifier (e.g. to
  /// ensure the ordering is correct).
  struct DispatchWrapper {
    let dispatch: Redux.Store.Dispatch
    let identifier: String
    
    init(_ identifier: String, _ dispatch: @escaping Redux.Store.Dispatch) {
      self.identifier = identifier
      self.dispatch = dispatch
    }
  }
}

public extension Redux.Middleware {
  
  /// Convenience container to expose basic store functionalities to allow
  /// middlewares.
  public struct Input<State> {
    public let lastState: Redux.Store.LastState<State>
    
    init(_ lastState: @escaping Redux.Store.LastState<State>) {
      self.lastState = lastState
    }
  }
  
  /// Function that maps one dispatch to another.
  public typealias DispatchMapper =
    (Redux.Store.DispatchWrapper) -> Redux.Store.DispatchWrapper
  
  /// Redux store middleware which has access to the store's functionalities.
  public typealias Middleware<State> = (Input<State>) -> DispatchMapper
  
  /// Combine middlewares into one single middleware, and wrap the store's
  /// dispatch with the combined middleware.
  ///
  /// - Parameters:
  ///   - store: A Store instance.
  ///   - middlewares: An Array of middlewares.
  /// - Returns: A wrapped dispatch instance.
  static func combineMiddlewares<S>(_ middlewares: [Middleware<S.State>])
    -> (S) -> Redux.Store.DispatchWrapper where
    S: ReduxStoreType
  {
    return {store in
      let input = Input(store.lastState)
      let rootWrapper = Redux.Store.DispatchWrapper("root", store.dispatch)
      
      if let firstMiddleware = middlewares.first {
        let restMiddlewares = Array(middlewares[1...])
        
        let combined = restMiddlewares.reduce(firstMiddleware, {(a, b) in
          {input in {a(input)(b(input)($0))}}
        })
      
        return combined(input)(rootWrapper)
      }
      
      return rootWrapper
    }
  }
  
  /// Apply a series of middlewares to a redux store.
  ///
  /// - Parameter middlewares: An Array of middlewares.
  /// - Returns: A Store instance.
  public static func applyMiddlewares<Store>(
    _ middlewares: [Middleware<Store.State>])
    -> (Store) -> Redux.Store.DelegateStore<Store.State> where
    Store: ReduxStoreType
  {
    return {store in
      let wrapper = combineMiddlewares(middlewares)(store)
      let enhanced = Redux.Store.EnhancedStore(store, wrapper.dispatch)
      return Redux.Store.DelegateStore(enhanced)
    }
  }
}
