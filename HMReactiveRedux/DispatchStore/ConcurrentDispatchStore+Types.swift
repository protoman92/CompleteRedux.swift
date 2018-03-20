//
//  ConcurrentDispatchStore+Types.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 20/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import SwiftFP

/// Convenience typealias for a concurrent generic dispatch store.
public typealias ConcurrentGenericDispatchStore<State> =
  ConcurrentDispatchStore<State, String, State>

public typealias ConcurrentTreeDispatchStore<V> =
  ConcurrentDispatchStore<TreeState<V>, (String, String), Try<V>>
