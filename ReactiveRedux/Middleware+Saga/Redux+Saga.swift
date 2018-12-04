//
//  Redux+Saga.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/3/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

extension Redux.Saga {
  public enum Error: LocalizedError {
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
  
  public struct Input<State> {
    public let lastState: Redux.Store.LastState<State>
    public let dispatchWrapper: Redux.Store.DispatchWrapper
    
    init(_ lastState: @escaping Redux.Store.LastState<State>,
         _ dispatchWrapper: Redux.Store.DispatchWrapper) {
      self.lastState = lastState
      self.dispatchWrapper = dispatchWrapper
    }
  }
  
  struct Output<T> {
    let onAction: Redux.Store.Dispatch
    private let source: Observable<T>
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
    
    func printValue() -> Output<T> {
      return self.with(source: source.do(onNext: {print($0)}))
    }
    
    func subscribe(_ callback: @escaping (T) -> Void) {
      self.source.subscribe(onNext: callback).disposed(by: self.disposeBag)
    }
  }
}
