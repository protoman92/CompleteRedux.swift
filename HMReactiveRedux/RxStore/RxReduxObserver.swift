//
//  RxReduxObserver.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 31/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftUtilities

/// Use this wrapper to discard completed events.
internal struct RxReduxObserver<Element> {
  fileprivate let reduxObserver: BehaviorRelay<E>

  public init(_ value: E) {
    reduxObserver = BehaviorRelay(value: value)
  }
  
  public var value: E {
    return reduxObserver.value
  }
}

extension RxReduxObserver: ObservableConvertibleType {
  internal func asObservable() -> Observable<E> {
    return reduxObserver.asObservable()
  }
}

extension RxReduxObserver: ObserverType {
  typealias E = Element

  internal func on(_ event: Event<Element>) {
    Preconditions.checkRunningOnMainThread(event)

    switch event {
    case .next(let element):
      reduxObserver.accept(element)

    case .error(let error):
      debugPrint("Received error: \(error), ignoring.")

    case .completed:
      debugPrint("Received completed event, ignoring.")
    }
  }
}
