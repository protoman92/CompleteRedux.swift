//
//  Redux+Saga+Take+Option.swift
//  SwiftRedux
//
//  Created by Hai Pham on 12/9/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import Foundation

/// Setup options for a take-related effect.
public struct TakeOptions {

  /// Create a new Builder instance.
  ///
  /// - Returns: A Builder instance.
  public static func builder() -> Builder {
    return Builder()
  }
  
  /// Create a default take options with no custom values.
  ///
  /// - Returns: A TakeOptions instance.
  public static func `default`() -> TakeOptions {
    return TakeOptions()
  }

  /// If this is greater than zero, emissions from a take effect will be
  /// debounced to prevent rapid values. Debouncing is useful for an
  /// autocomplete search implementation.
  public internal(set) var debounce: TimeInterval = 0
  
  init() {}
  
  /// Builder for a take effect options.
  public final class Builder {
    private var options: TakeOptions
    
    fileprivate init(options: TakeOptions = .init()) {
      self.options = options
    }
    
    /// Set the debounce interval.
    ///
    /// - Parameter debounce: A TimeInterval value.
    /// - Returns: The current Builder instance.
    public func with(debounce: TimeInterval) -> Self {
      self.options.debounce = debounce
      return self
    }
    
    /// Get the built take options.
    ///
    /// - Returns: A TakeOptions instance.
    public func build() -> TakeOptions {
      return self.options
    }
  }
}
