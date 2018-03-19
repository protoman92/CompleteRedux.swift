//
//  ReduxObserverTest.swift
//  HMReactiveReduxTests
//
//  Created by Hai Pham on 19/3/18.
//  Copyright © 2018 Holmusk. All rights reserved.
//

import RxSwift
import SwiftUtilities
import XCTest
@testable import HMReactiveRedux

public final class ReduxObserverTest {
  public func test_reduxObserver_shouldIgnoreErrorAndCompleteEvents() {
    /// Setup
    let reduxObserver = RxReduxObserver<Int>(0)
    
    /// When
    reduxObserver.on(.error(Exception("")))
    reduxObserver.on(.completed)
    reduxObserver.on(.next(1))
    
    /// Then
    XCTAssertEqual(reduxObserver.value, 1)
  }
}
