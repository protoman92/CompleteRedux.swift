//
//  Redux+Saga.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift
import SwiftFP

extension Redux.Saga {

  /// Errors specific to Redux Saga.
  public enum Error: LocalizedError {
    
    /// Represents a lack of implementation.
    case unimplemented
    
    public var localizedDescription: String {
      switch self {
      case .unimplemented:
        return "Should have implemented this method"
      }
    }
    
    public var errorDescription: String? {
      return self.localizedDescription
    }
  }
  
  /// Input for each saga effect.
  public struct Input<State> {
    let lastState: Redux.Store.LastState<State>
    let dispatch: Redux.Store.Dispatch
    
    init(_ lastState: @escaping Redux.Store.LastState<State>,
         _ dispatch: @escaping Redux.Store.Dispatch) {
      self.lastState = lastState
      self.dispatch = dispatch
    }
  }
  
  /// Output for each saga effect. This is simply a wrapper for Observable.
  public struct Output<T> {
    let onAction: Redux.Store.Dispatch
    let source: Observable<T>
    private let disposeBag: DisposeBag
    
    init(_ source: Observable<T>, _ onAction: @escaping Redux.Store.Dispatch) {
      self.onAction = onAction
      self.source = source
      self.disposeBag = DisposeBag()
    }
    
    func with<R>(source: Observable<R>) -> Output<R> {
      return Output<R>(source, self.onAction)
    }
    
    func map<R>(_ fn: @escaping (T) throws -> R) -> Output<R> {
      return self.with(source: self.source.map(fn))
    }
    
    func flatMap<R>(_ fn: @escaping (T) throws -> Output<R>) -> Output<R> {
      return self.with(source: self.source.map(fn).flatMap({$0.source}))
    }
    
    func flatMap<R>(_ fn: @escaping (T) throws -> Observable<R>) -> Output<R> {
      return self.with(source: self.source.flatMap(fn))
    }
    
    func switchMap<R>(_ fn: @escaping (T) throws -> Output<R>) -> Output<R> {
      return self.with(source: self.source.map(fn).flatMapLatest({$0.source}))
    }
    
    func catchError(_ fn: @escaping (Swift.Error) throws -> Output<T>) -> Output<T> {
      return self.with(source: self.source.catchError({try fn($0).source}))
    }
    
    func delay(bySeconds sec: TimeInterval,
               usingQueue dispatchQueue: DispatchQueue) -> Output<T> {
      let scheduler = ConcurrentDispatchQueueScheduler(queue: dispatchQueue)
      return self.with(source: self.source.delay(sec, scheduler: scheduler))
    }
    
    public func debounce(
      bySeconds sec: TimeInterval,
      usingQueue dispatchQueue: DispatchQueue = .global(qos: .default))
      -> Output<T>
    {
      let scheduler = ConcurrentDispatchQueueScheduler(queue: dispatchQueue)
      return self.with(source: self.source.debounce(sec, scheduler: scheduler))
    }
    
    func printValue() -> Output<T> {
      return self.with(source: source.do(onNext: {print($0)}))
    }
    
    func observeOn(_ scheduler: SchedulerType) -> Output<T> {
      return self.with(source: self.source.observeOn(scheduler))
    }
    
    func subscribe(_ callback: @escaping (T) -> Void) {
      self.source.subscribe(onNext: callback).disposed(by: self.disposeBag)
    }
    
    /// Get the next value of the stream on the current thread.
    ///
    /// - Parameter nano: The time in nanoseconds to wait for until timeout.
    /// - Returns: A Try instance.
    public func nextValue(timeoutInNanoseconds nano: Double) -> Try<T> {
      let dispatchGroup = DispatchGroup()
      var value: Try<T> = Try.failure("No value found")
      dispatchGroup.enter()
      
      self.source.take(1)
        .subscribe(
          onNext: {value = Try.success($0); dispatchGroup.leave()},
          onError: {value = Try.failure($0); dispatchGroup.leave()})
        .disposed(by: self.disposeBag)

      let dispatchTimeout = DispatchTime(uptimeNanoseconds:
        DispatchTime.now().uptimeNanoseconds + UInt64(nano))
      
      _ = dispatchGroup.wait(timeout: dispatchTimeout)
      return value
    }
    
    /// Get the next value of a stream on the current thread.
    ///
    /// - Parameter millis: The time in milliseconds to wait for until timeout.
    /// - Returns: A Try instance.
    public func nextValue(timeoutInMilliseconds millis: Double) -> Try<T> {
      return self.nextValue(timeoutInNanoseconds: millis * pow(10, 6))
    }
    
    /// Get the next value of a stream on the current thread.
    ///
    /// - Parameter seconds: The time in seconds to wait for until timeout.
    /// - Returns: A Try instance.
    public func nextValue(timeoutInSeconds seconds: Double) -> Try<T> {
      return self.nextValue(timeoutInMilliseconds: seconds * pow(10, 3))
    }
  }
}
