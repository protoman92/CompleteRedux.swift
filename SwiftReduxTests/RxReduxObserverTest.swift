//
//  RxReduxObserverTest.swift
//  SwiftReduxTests
//
//  Created by Hai Pham on 19/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import XCTest
@testable import SwiftRedux

final class RxReduxObserverTest: XCTestCase {
  func test_reduxObserver_shouldIgnoreErrorAndCompleteEvents() {
    /// Setup
    let reduxObserver = Redux.Store.RxObserver<Int>(0)
    
    /// When
    reduxObserver.on(.error(self))
    reduxObserver.on(.completed)
    reduxObserver.on(.next(1))
    
    /// Then
    XCTAssertEqual(try! reduxObserver.value(), 1)
  }
}

extension RxReduxObserverTest: Error {}
