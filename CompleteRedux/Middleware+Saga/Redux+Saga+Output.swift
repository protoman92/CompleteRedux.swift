//
//  Redux+Saga+Output.swift
//  CompleteRedux
//
//  Created by Viethai Pham on 11/3/19.
//  Copyright © 2019 Hai Pham. All rights reserved.
//

import RxSwift
import RxBlocking

/// Output for each saga effect. This is simply a wrapper for Observable.
public final class SagaOutput<T>: Awaitable<T> {  
  let monitor: SagaMonitorType
  let onAction: AwaitableReduxDispatcher
  let source: Observable<T>
  
  /// Create a Saga output instance. We need to register this output with a
  /// Saga monitor to trigger action dispatcher when one arrives.
  ///
  /// - Parameters:
  ///   - monitor: A Saga monitor instance.
  ///   - source: An Observable instance.
  ///   - onAction: An action dispatcher.
  init(_ monitor: SagaMonitorType,
       _ source: Observable<T>,
       _ onAction: @escaping AwaitableReduxDispatcher = NoopDispatcher.instance) {
    self.monitor = monitor
    self.onAction = onAction
    let uniqueID = DefaultUniqueIDProvider.next()
    
    self.source = source.do(
      onNext: nil,
      onError: nil,
      onCompleted: nil,
      onSubscribe: nil,
      onSubscribed: {monitor.addDispatcher(uniqueID, onAction)},
      onDispose: {monitor.removeDispatcher(uniqueID)})
  }
  
  func with<R>(source: Observable<R>) -> SagaOutput<R> {
    return SagaOutput<R>(self.monitor, source)
  }
  
  func flatMap<R>(_ fn: @escaping (T) throws -> SagaOutput<R>) -> SagaOutput<R> {
    return self.with(source: self.source.map(fn).flatMap({$0.source}))
  }
  
  func switchMap<R>(_ fn: @escaping (T) throws -> SagaOutput<R>) -> SagaOutput<R> {
    return self.with(source: self.source.map(fn).flatMapLatest({$0.source}))
  }
  
  func debounce(bySeconds sec: TimeInterval,
                usingScheduler scheduler: SchedulerType) -> SagaOutput<T> {
    return self.with(source: self.source.debounce(sec, scheduler: scheduler))
  }
  
  func subscribe(_ callback: @escaping (T) -> Void) -> Disposable {
    return self.source.subscribe(onNext: callback)
  }
  
  override public func await() throws -> T {
    return try self.source.toBlocking().first().getOrThrow(SagaError.unavailable)
  }
  
  override public func await(timeoutMillis: Double) throws -> T {
    return try self.source
      .toBlocking(timeout: timeoutMillis).first()
      .getOrThrow(SagaError.unavailable)
  }
}
