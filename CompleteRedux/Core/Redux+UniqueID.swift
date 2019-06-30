//
//  Redux+UniqueID.swift
//  CompleteRedux
//
//  Created by Viethai Pham on 11/3/19.
//  Copyright © 2019 Swiften. All rights reserved.
//

import Foundation

/// Utility class to automatically provide an ever-incrementing value. The
/// increments are performed atomically.
public class DefaultUniqueIDProvider {
  
  /// The current value.
  private static var current: Int64 = -1
  
  /// Get the next available unique ID.
  ///
  /// - Returns: A UniqueID instance.
  public static func next() -> UniqueIDProviderType.UniqueID {
    return OSAtomicIncrement64(&self.current)
  }
  
  init() {}
}
