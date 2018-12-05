//
//  Redux+Saga+Effect.swift
//  ReactiveRedux
//
//  Created by Hai Pham on 12/4/18.
//  Copyright © 2018 Hai Pham. All rights reserved.
//

import RxSwift

extension Redux.Saga {

  /// Base class for a side effect. Subclasses must override the main invocation
  /// method to customize the saga output.
  public class Effect<State, R>: ReduxSagaEffectType {
    public func invoke(_ input: Input<State>) -> Output<R> {
      return Output(.error(Redux.Saga.Error.unimplemented), {_ in})
    }
  }
  
  /// Empty effect whose output does not emit anything.
  final class EmptyEffect<State, R>: Effect<State, R> {
    override func invoke(_ input: Input<State>) -> Output<R> {
      return Output(.empty(), {_ in})
    }
  }
  
  /// Effect whose output simply emits some specified element.
  final class JustEffect<State, R>: Effect<State, R> {
    private let value: R
    
    init(_ value: R) {
      self.value = value
    }
    
    override func invoke(_ input: Input<State>) -> Output<R> {
      return Output(.just(self.value), {_ in})
    }
  }
  
  /// Effect whose output selects some value from a redux store's managed state.
  /// The extracted value can then be fed to other effects that require params.
  final class SelectEffect<State, R>: Effect<State, R> {
    private let _selector: (State) -> R
    
    init(_ selector: @escaping (State) -> R) {
      self._selector = selector
    }
    
    override func invoke(_ input: Input<State>) -> Output<R> {
      return Output(.just(self._selector(input.lastState())), {_ in})
    }
  }
  
  /// Effect whose output puts some external value into the redux store's
  /// managed state. We may also want to specify the dispatch queue on which
  /// to dispatch the action so that specific order (e.g. serial) may be
  /// achieved.
  final class PutEffect<State, P>: Effect<State, Any> {
    private let _actionCreator: (P) -> ReduxActionType
    private let _param: E<State, P>
    private let _dispatchQueue: DispatchQueue
    
    init(_ param: E<State, P>,
         _ actionCreator: @escaping (P) -> ReduxActionType,
         _ dispatchQueue: DispatchQueue) {
      self._actionCreator = actionCreator
      self._param = param
      self._dispatchQueue = dispatchQueue
    }
    
    override func invoke(_ input: Input<State>) -> Output<Any> {
      return _param.invoke(input)
        .map(self._actionCreator)
        .observeOn(ConcurrentDispatchQueueScheduler(queue: self._dispatchQueue))
        .map(input.dispatch)
    }
  }
  
  /// Effect whose output performs some asynchronous work and then emit the
  /// result.
  final class CallEffect<State, P, R>: Effect<State, R> {
    private let _param: E<State, P>
    private let _callCreator: (P) -> Observable<R>
    
    init(_ param: E<State, P>,
         _ callCreator: @escaping (P) -> Observable<R>) {
      self._param = param
      self._callCreator = callCreator
    }
    
    override func invoke(_ input: Input<State>) -> Output<R> {
      return self._param.invoke(input).flatMap(self._callCreator)
    }
  }
  
  /// Effect whose output is the result of sequentializing the outputs of two
  /// effects. Use this effect to make sure one effect happens after another.
  final class SequentializeEffect<E1, E2, U>: Effect<E2.State, U> where
    E1: ReduxSagaEffectType,
    E2: ReduxSagaEffectType,
    E1.State == E2.State
  {
    private let effect1: E1
    private let effect2: E2
    private let combineFunc: (E1.R, E2.R) throws -> U
    
    init(_ effect1: E1,
         _ effect2: E2,
         _ combineFunc: @escaping (E1.R, E2.R) throws -> U) {
      self.effect1 = effect1
      self.effect2 = effect2
      self.combineFunc = combineFunc
    }
    
    override func invoke(_ input: Input<State>) -> Output<U> {
      return self.effect1.invoke(input).flatMap({result1 in
        self.effect2.invoke(input).map({try self.combineFunc(result1, $0)})})
    }
  }
}

extension Redux.Saga {
  /// Take effects are streams that filter actions and pluck out the appropriate
  /// ones to perform additional work on.
  class TakeEffect<State, Action, P, R>: Effect<State, R> where
    Action: ReduxActionType
  {
    private let _paramExtractor: (Action) -> P?
    private let _effectCreator: (P) -> E<State, R>
    private let _outputFlattener: (Output<Output<R>>) -> Output<R>
    
    init(_ actionType: Action.Type,
         _ paramExtractor: @escaping (Action) -> P?,
         _ outputCreator: @escaping (P) -> E<State, R>,
         _ outputFlattener: @escaping (Output<Output<R>>) -> Output<R>) {
      self._paramExtractor = paramExtractor
      self._effectCreator = outputCreator
      self._outputFlattener = outputFlattener
    }
    
    override func invoke(_ input: Input<State>) -> Output<R> {
      let paramStream = PublishSubject<P>()
      
      return self._outputFlattener(Output
        .init(paramStream, {($0 as? Action)
          .flatMap(self._paramExtractor)
          .map(paramStream.onNext)})
        .map({self._effectCreator($0).invoke(input)}))
    }
  }
  
  /// Effect whose output takes all actions that pass some conditions, then
  /// flattens and emits all values. Contrast this with take latest.
  final class TakeEveryEffect<State, Action, P, R>:
    TakeEffect<State, Action, P, R> where Action: ReduxActionType
  {
    init(_ actionType: Action.Type,
         _ paramExtractor: @escaping (Action) -> P?,
         _ outputCreator: @escaping (P) -> E<State, R>) {
      super.init(actionType, paramExtractor, outputCreator, {$0.flatMap({$0})})
    }
  }
  
  /// Effect whose output switches to the latest action every time one arrives.
  /// This is best used for cases whereby we are only interested in the latest
  /// value, such as in an autocomplete implementation. We define the type of
  /// action and param extractor to filter out actions we are not interested in.
  final class TakeLatestEffect<State, Action, P, R>:
    TakeEffect<State, Action, P, R> where Action: ReduxActionType
  {
    init(_ actionType: Action.Type,
         _ paramExtractor: @escaping (Action) -> P?,
         _ outputCreator: @escaping (P) -> E<State, R>) {
      super.init(actionType, paramExtractor, outputCreator, {$0.switchMap({$0})})
    }
  }
}
