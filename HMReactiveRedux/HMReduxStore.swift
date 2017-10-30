//
//  HMReduxStore.swift
//  HMReactiveRedux
//
//  Created by Hai Pham on 27/10/17.
//  Copyright © 2017 Holmusk. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftUtilities

/// A Redux-compliant store.
public struct HMReduxStore<S: HMStateType> {
    
    /// Create a redux store that only receives and delivers events on the main
    /// thread.
    ///
    /// - Parameters:
    ///   - initialState: A State instance.
    ///   - mainReducer: A HMReducer instance.
    /// - Returns: A HMReduxStore instance.
    public static func mainThreadVariant(
        _ initialState: State,
        _ mainReducer: @escaping HMReducer<State>) -> HMReduxStore<State>
    {
        let actionSubject = BehaviorSubject<Action?>(value: nil)
        let stateSubject = BehaviorSubject<S>(value: initialState)
        
        return HMReduxStore<State>.builder()
            .with(actionTrigger: actionSubject)
            .with(actionStream: actionSubject.asDriver(onErrorJustReturn: nil))
            .with(stateTrigger: stateSubject)
            .with(stateStream: stateSubject.asDriver(onErrorJustReturn: initialState))
            .build(withInitialState: initialState, reducer: mainReducer)
    }
    
    fileprivate let disposeBag: DisposeBag
    fileprivate var rdActionTrigger: AnyObserver<Action?>?
    fileprivate var rdActionStream: Observable<Action?>?
    fileprivate var rdStateTrigger: AnyObserver<State>?
    fileprivate var rdStateStream: Observable<State>?
    
    fileprivate init() {
        disposeBag = DisposeBag()
    }
    
    fileprivate func setupStateBindings(_ initialState: State,
                                        _ reducer: @escaping HMReducer<State>) {
        let disposeBag = self.disposeBag
        
        createState(actionStream(), initialState, reducer)
            .bind(to: stateTrigger())
            .disposed(by: disposeBag)
    }
}

extension HMReduxStore: HMReduxStoreType {
    public typealias State = S
    
    public func actionTrigger() -> AnyObserver<Action?> {
        if let actionTrigger = rdActionTrigger {
            return actionTrigger
        } else {
            fatalError("Action trigger cannot be nil")
        }
    }
    
    public func actionStream() -> Observable<Action> {
        if let actionStream = rdActionStream {
            return actionStream.mapNonNilOrEmpty()
        } else {
            fatalError("Action stream cannot be nil")
        }
    }
    
    public func stateTrigger() -> AnyObserver<State> {
        if let stateTrigger = rdStateTrigger {
            return stateTrigger
        } else {
            fatalError("State trigger cannot be nil")
        }
    }
    
    public func stateStream() -> Observable<State> {
        if let stateStream = rdStateStream {
            return stateStream
        } else {
            fatalError("State stream cannot be nil")
        }
    }
}

extension HMReduxStore: BuildableType {
    public static func builder() -> Builder {
        return Builder()
    }
    
    public final class Builder {
        fileprivate var store: Buildable
        
        fileprivate init() {
            store = HMReduxStore()
        }
        
        /// Set the action trigger.
        ///
        /// - Parameter actionTrigger: An Observer instance.
        /// - Returns: The current Builder instance.
        @discardableResult
        public func with<O>(actionTrigger: O?) -> Self where
            O: ObserverType, O.E == Action?
        {
            store.rdActionTrigger = actionTrigger?.asObserver()
            return self
        }
        
        /// Set the action stream.
        ///
        /// - Parameter actionStream: An Observable instance.
        /// - Returns: The current Builder instance.
        @discardableResult
        public func with<O>(actionStream: O?) -> Self where
            O: ObservableConvertibleType, O.E == Action?
        {
            store.rdActionStream = actionStream?.asObservable()
            return self
        }
        
        /// Set the state trigger.
        ///
        /// - Parameter stateTrigger: An Observer instance.
        /// - Returns: The current Builder instance.
        @discardableResult
        public func with<O>(stateTrigger: O?) -> Self where
            O: ObserverType, O.E == State
        {
            store.rdStateTrigger = stateTrigger?.asObserver()
            return self
        }
        
        /// Set the state stream.
        ///
        /// - Parameter stateStream: An Observable instance.
        /// - Returns: The current Builder instance.
        @discardableResult
        public func with<O>(stateStream: O?) -> Self where
            O: ObservableConvertibleType, O.E == State
        {
            store.rdStateStream = stateStream?.asObservable()
            return self
        }
        
        /// Build with state bindings.
        ///
        /// - Parameter
        ///   - state: A State instance.
        ///   - reducer: A HMReducer instance.
        /// - Returns: The Buildable instance.
        public func build(withInitialState state: State,
                          reducer: @escaping HMReducer<State>) -> Buildable {
            store.setupStateBindings(state, reducer)
            return build()
        }
    }
}

extension HMReduxStore.Builder: BuilderType {
    public typealias Buildable = HMReduxStore
    
    @discardableResult
    public func with(buildable: Buildable?) -> Self {
        if let buildable = buildable {
            return self
                .with(actionTrigger: buildable.rdActionTrigger)
                .with(actionStream: buildable.rdActionStream)
                .with(stateTrigger: buildable.rdStateTrigger)
                .with(stateStream: buildable.rdStateStream)
        } else {
            return self
        }
    }
    
    public func build() -> Buildable {
        return store
    }
}
