//
//  TreeDispatchStoreType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 20/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftFP

/// Represents a Tree-based dispatch store.
public protocol TreeDispatchStoreType: DispatchReduxStoreType where
  State == TreeState<Value>,
  Registry == (String, String),
  CBValue == Try<Value>
{
  associatedtype Value
}
