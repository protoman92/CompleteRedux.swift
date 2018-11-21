//
//  ReduxPresetTest.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 17/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SafeNest
import SwiftUtilities
import XCTest
@testable import HMReactiveRedux

public final class ReduxPresetTest: XCTestCase {
  public func test_defaultAction_shouldWork() {
    /// Setup
    let initialObject = [String : Int]()
    var state = SafeNest(initialObject: initialObject)

    /// When
    state = DefaultRedux.Reducer.reduce(state, DefaultRedux.Action.noop)!

    /// Then
    XCTAssertEqual(state.object as! [String : Int], initialObject)
  }
}
