//
//  RxReduxObserver.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 31/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxSwift

/// Use this wrapper to discard completed events.
internal struct RxReduxObserver<Element> {
  fileprivate let reduxObserver: BehaviorSubject<E>

  public init(_ value: E) {
    reduxObserver = BehaviorSubject(value: value)
  }
  
  public func value() throws -> E {
    return try reduxObserver.value()
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
    #if DEBUG
    if !Thread.isMainThread {
      fatalError("Should receive \(event) on main thread")
    }
    #endif

    switch event {
    case .next(let element):
      reduxObserver.onNext(element)

    case .error(let error):
      debugPrint("Received error: \(error), ignoring.")

    case .completed:
      debugPrint("Received completed event, ignoring.")
    }
  }
}
