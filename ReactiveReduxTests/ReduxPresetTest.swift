//
//  ReduxPresetTest.swift
//  ReactiveReduxTests
//
//  Created by Hai Pham on 17/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SafeNest
import XCTest
@testable import ReactiveRedux

public final class ReduxPresetTest: XCTestCase {
  public func test_defaultAction_shouldWork() {
    /// Setup
    let initialObject = [String : Int]()
    var state = SafeNest.builder().with(initialObject: initialObject).build()

    /// When
    state = Redux.DefaultReducer.reduce(state, Redux.DefaultAction.noop)!

    /// Then
    XCTAssertEqual(state.object as! [String : Int], initialObject)
  }
}
