//
//  ReduxLockTest.swift
//  ReactiveReduxTests
//
//  Created by Hai Pham on 12/12/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import XCTest
@testable import ReactiveRedux

final class ReduxLockTest: XCTestCase {
  #if DEBUG
  func test_readWriteLock_shouldDestroyLockOnDeinit() {
    /// Setup
    var lock = pthread_rwlock_t()
    var disposableLock: Redux.ReadWriteLock? = .init(&lock)
    let dispatchGroup = DispatchGroup()
    
    dispatchGroup.enter()
    
    /// When
    XCTAssertEqual(disposableLock?.lockRead(tryAcquire: false), true)
    XCTAssertEqual(disposableLock?.unlock(), true)
    XCTAssertEqual(disposableLock?.lockWrite(tryAcquire: false), true)
    XCTAssertEqual(disposableLock?.unlock(), true)
    
    DispatchQueue.global(qos: .background).async {
      disposableLock = nil
      dispatchGroup.leave()
    }
    
    dispatchGroup.wait()
    
    /// Then
    XCTAssertNotEqual(pthread_rwlock_destroy(&lock), 0)
  }
  #endif
}
