//
//  GenericDispatchStoreType.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 20/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

/// Represents a generic dispatch store with custom state.
public protocol GenericDispatchStoreType: DispatchReduxStoreType where
  Registry == String,
  CBValue == State {}
