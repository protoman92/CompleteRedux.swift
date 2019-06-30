//
//  Redux+Subscription.swift
//  CompleteReduxTests
//
//  Created by Viethai Pham on 12/3/19.
//  Copyright © 2019 Holmusk. All rights reserved.
//

import XCTest
@testable import CompleteRedux

class ReduxSubscriptionTest: XCTestCase {
  public func test_noopSubscription_shouldNotDoAnything() {
    ReduxSubscription.noop.unsubscribe()
  }
}
