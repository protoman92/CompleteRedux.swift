//
//  RxReduxObserverTest.swift
//  ReactiveReduxTests
//
//  Created by Hai Pham on 19/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import XCTest
@testable import ReactiveRedux

public final class RxReduxObserverTest: XCTestCase {
  public func test_reduxObserver_shouldIgnoreErrorAndCompleteEvents() {
    /// Setup
    let reduxObserver = RxReduxObserver<Int>(0)
    
    /// When
    reduxObserver.on(.error(self))
    reduxObserver.on(.completed)
    reduxObserver.on(.next(1))
    
    /// Then
    XCTAssertEqual(try! reduxObserver.value(), 1)
  }
}

extension RxReduxObserverTest: Error {}
