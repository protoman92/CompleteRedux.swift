//
//  ReduxPresetTest.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 17/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import SwiftUtilities
import XCTest
@testable import HMReactiveRedux

public final class ReduxPresetTest: XCTestCase {
  public func test_errorActions_shouldWork() {
    /// Setup
    var state = TreeState<Any>.empty()
    let errorMsg = "Error!"
    let error = Exception(errorMsg)

    /// When
    let action = GeneralReduxAction.Error.Display.updateShowError(error)
    state = GeneralReduxReducer.generalReducer(state, action)

    /// Then
    let result = state.stateValue(GeneralReduxAction.Error.Display.errorPath).value!
    XCTAssertTrue(result is Error)
    XCTAssertEqual((result as! Error).localizedDescription, errorMsg)
  }

  public func test_globalActions_shouldWork() {
    /// Setup
    var state = TreeState<Any>.empty()
    state = state.updateValue("a.b.c", 1)
    assert(!state.isEmpty)

    /// When
    let action = GeneralReduxAction.Global.clearAll
    state = GeneralReduxReducer.generalReducer(state, action)

    /// Then
    XCTAssertTrue(state.isEmpty)
  }

  public func test_progressActions_shouldWork() {
    /// Setup
    var state = TreeState<Any>.empty()

    /// When
    let action = GeneralReduxAction.Progress.Display.updateShowProgress(true)
    state = GeneralReduxReducer.generalReducer(state, action)

    /// Then
    let result = state.stateValue(GeneralReduxAction.Progress.Display.progressPath).value!
    XCTAssertTrue(result is Bool)
    XCTAssertTrue(result as! Bool)
  }
}
