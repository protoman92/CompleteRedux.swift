//
//  ReduxSubscription.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/1/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

/// Subscription that can be unsubscribed from. This allows subscribers to
/// store state to cancel anytime they want.
public struct ReduxSubscription {
  public let unsubscribe: () -> Void
  
  init(_ unsubscribe: @escaping () -> Void) {
    self.unsubscribe = unsubscribe
  }
}
