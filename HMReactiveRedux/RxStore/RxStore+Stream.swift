//
//  RxReduxStore+Stream.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 28/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

public extension RxStore {

  /// Subscribe to this stream to receive notifications for a particular
  /// substate.
  ///
  /// - Parameter identifier: A String value.
  /// - Returns: An Observable instance.
  public func substateStream(_ identifier: String) -> Observable<Try<State>> {
    return stateStream().map({$0.substate(identifier)})
  }

  /// Subscribe to this stream to receive notifications for a particular
  /// state value.
  ///
  /// - Parameter identifier: A String value.
  /// - Returns: An Observable instance.
  public func stateValueStream(_ identifier: String) -> Observable<Try<Value>> {
    return stateStream().map({$0.stateValue(identifier)})
  }

  /// Subscribe to this stream to receive notifications for a state value of
  /// a specified type.
  ///
  /// - Parameters:
  ///   - cls: The T class type.
  ///   - identifier: A String value.
  /// - Returns: An Observable instance.
  public func stateValueStream<T>(_ cls: T.Type, _ identifier: String) -> Observable<Try<T>> {
    return stateValueStream(identifier).map({$0.flatMap({$0 as? T})})
  }
}
