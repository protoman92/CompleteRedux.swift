//
//  RxReduxObserver.swift
//  SwiftRedux
//
//  Created by Hai Pham on 31/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxSwift

public extension Redux.Store {
  
  /// Use this wrapper to discard error/complete events.
  public struct RxObserver<Element> {
    private let _observer: BehaviorSubject<E>

    init(_ value: E) {
      self._observer = BehaviorSubject(value: value)
    }
    
    public func value() throws -> E {
      return try self._observer.value()
    }
  }
}

extension Redux.Store.RxObserver: ObservableConvertibleType {
  public func asObservable() -> Observable<E> {
    return self._observer.asObservable()
  }
}

extension Redux.Store.RxObserver: ObserverType {
  public typealias E = Element

  public func on(_ event: Event<Element>) {
    switch event {
    case .next(let element):
      self._observer.onNext(element)

    case .error(let error):
      debugPrint("Received error: \(error), ignoring.")

    case .completed:
      debugPrint("Received completed event, ignoring.")
    }
  }
}
