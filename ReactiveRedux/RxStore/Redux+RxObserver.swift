//
//  RxReduxObserver.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 31/10/17.
//  Copyright © 2017 Hai Pham. All rights reserved.
//

import RxSwift

public extension Redux {
  
  /// Use this wrapper to discard error/complete events.
  public struct RxObserver<Element> {
    private let observer: BehaviorSubject<E>

    init(_ value: E) {
      self.observer = BehaviorSubject(value: value)
    }
    
    public func value() throws -> E {
      return try self.observer.value()
    }
  }
}

extension Redux.RxObserver: ObservableConvertibleType {
  public func asObservable() -> Observable<E> {
    return self.observer.asObservable()
  }
}

extension Redux.RxObserver: ObserverType {
  public typealias E = Element

  public func on(_ event: Event<Element>) {
    #if DEBUG
    if !Thread.isMainThread {
      fatalError("Should receive \(event) on main thread")
    }
    #endif

    switch event {
    case .next(let element):
      self.observer.onNext(element)

    case .error(let error):
      debugPrint("Received error: \(error), ignoring.")

    case .completed:
      debugPrint("Received completed event, ignoring.")
    }
  }
}
