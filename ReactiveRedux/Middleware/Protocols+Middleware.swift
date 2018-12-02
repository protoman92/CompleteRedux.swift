//
//  Protocols+Middleware.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/2/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Middleware provider that can be used to wrap a base store.
public protocol ReduxMiddlewareProviderType {
  associatedtype State
  
  /// Create a dispatch mapper from some input.
  ///
  /// - Parameter input: A middleware input instance.
  /// - Returns: A Dispatch mapper instance.
  func wrap(_ input: Redux.MiddlewareInput<State>) -> Redux.DispatchMapper
}
