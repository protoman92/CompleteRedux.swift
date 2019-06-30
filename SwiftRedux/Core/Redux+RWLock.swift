//
//  Redux+RWLock.swift
//  SwiftRedux
//
//  Created by Hai Pham on 12/12/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import Foundation

/// Simple read-write lock implementation with pthread_rwlock_t.
public final class ReadWriteLock: ReadWriteLockType {
  private var mainLock: pthread_rwlock_t
  
  /// Initialize a new read-write lock with pthread_rwlock_t.
  public init() {
    self.mainLock = pthread_rwlock_t()
    pthread_rwlock_init(&self.mainLock, nil)
  }
  
  #if DEBUG
  /// Use this initializer during testing to check state of the lock.
  init(_ lock: inout pthread_rwlock_t) {
    self.mainLock = lock
    pthread_rwlock_init(&self.mainLock, nil)
  }
  #endif
  
  deinit {pthread_rwlock_destroy(&self.mainLock)}
  
  public func lockRead() {
    pthread_rwlock_rdlock(&self.mainLock)
  }
  
  public func lockWrite() {
    pthread_rwlock_wrlock(&self.mainLock)
  }
  
  public func unlock() {
    pthread_rwlock_unlock(&self.mainLock)
  }
}
