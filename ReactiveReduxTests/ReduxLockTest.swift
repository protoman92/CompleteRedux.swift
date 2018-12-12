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
    XCTAssertEqual(disposableLock?.lockRead(force: true), true)
    XCTAssertEqual(disposableLock?.unlock(), true)
    XCTAssertEqual(disposableLock?.lockWrite(force: true), true)
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
  
  func test_lockableObject_shouldReturnNilWhenDeadlock() {
    /// Setup
    let lock = Redux.ReadWriteLock()
    let lockable = Lockable(lock)
    var readCount = 0
    var writeCount = 0
    defer {lock.unlock()}
    
    /// When
    lock.lockWrite(force: true)
    lockable.modify {writeCount += 1}
    let readResult = lockable.access {() -> Int in readCount += 1; return 1}
    
    /// Then
    XCTAssertNil(readResult)
    XCTAssertEqual(readCount, 0)
    XCTAssertEqual(writeCount, 0)
  }
}

extension ReduxLockTest {
  final class Lockable: ReadWriteLockableType {
    let lock: ReadWriteLockType
    
    init(_ lock: Redux.ReadWriteLock) {
      self.lock = lock
    }
  }
}
