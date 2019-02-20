//
//  ReduxPresetTest.swift
//  SwiftReduxTests
//
//  Created by Hai Pham on 17/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SafeNest
import XCTest
@testable import SwiftRedux

final class ReduxPresetTest: XCTestCase {
  override func setUp() {
    super.setUp()
    _ = Redux()
    _ = Redux.Middleware()
    _ = Redux.Preset()
    _ = Redux.Preset.Reducer()
    _ = Redux.Saga()
    _ = Redux.Store()
    _ = Redux.UI()
  }
  
  func test_defaultAction_shouldWork() {
    /// Setup
    let initialObject = [String : Int]()
    var state = SafeNest.builder().with(initialObject: initialObject).build()

    /// When
    state = Redux.Preset.Reducer.reduce(state, Redux.Preset.Action.noop)

    /// Then
    XCTAssertEqual(state.object as! [String : Int], initialObject)
  }
}
